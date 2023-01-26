defmodule Store.Inventory.Integration do
  alias Store.Repo
  alias Ecto.Multi
  alias Store.Inventory.{Product, CustomerProduct, PricingTier}
  alias Store.Messaging.{CampaignProduct}

  alias Store.Inventory.Integration.{
    ProductIntegration,
    ProductSyncItem,
    Xyz,
    Abc
  }

  @doc """
  Validate the api key for the integration by name
  """
  def validate_product_integration(args) do
    case args.name do
      "xyz" -> {:ok, Xyz.validate_api_key(args.api_key)}
      "abc" -> {:ok, Abc.validate_api_key(args.client_id, args.api_key)}
      _ -> {:ok, false}
    end
  end

  @doc """
  Return the product integration record for the provided location_id
  """
  def get_product_integration(location_id) do
    ProductIntegration.get_by_location(location_id)
  end

  @doc """
  Return the product sync items for the provided location_id with provided options
  """
  def get_product_sync_items(location_id, options) do
    case ProductSyncItem.get_all_not_imported(location_id, options) do
      {:error, _error} -> {:error, "Could not get product sync items"}
      {:ok, items} -> {:ok, items}
      items -> {:ok, items}
    end
  end

  @doc """
  Create or update the product integration record
  """
  def set_product_integration(integration) do
    ProductIntegration.create(integration)
  end

  @doc """
  Save sync item along with product and tier within a transaction
  """
  def save_product_sync_item(sync_item) do
    sync_item =
      sync_item
      |> Map.put(:is_imported, true)

    existing_sync_item =
      ProductSyncItem
      |> Repo.get(sync_item.id)

    sync_changeset =
      existing_sync_item
      |> ProductSyncItem.changeset(sync_item)

    pricing_tier =
      existing_sync_item.prices
      |> Map.put("location_id", sync_item.location_id)

    pricing_tier_changeset = PricingTier.changeset(%PricingTier{}, pricing_tier)

    multi =
      Multi.new()
      |> Multi.update(:product_sync_item, sync_changeset)
      |> Multi.insert(:pricing_tier, pricing_tier_changeset)
      |> Multi.run(:product, fn _repo,
                                %{
                                  product_sync_item: product_sync_item,
                                  pricing_tier: pricing_tier
                                } ->
        product_sync_item
        |> Map.take([
          :name,
          :description,
          :image,
          :type,
          :is_active,
          :in_stock,
          :location_id,
          :category_id
        ])
        |> Map.put(:tier_id, pricing_tier.id)
        |> Map.put(:location_id, sync_item.location_id)
        |> Map.put(:sync_item_id, product_sync_item.id)
        |> Product.create()
      end)
      |> Multi.run(:pricing_tier_update, fn _repo,
                                            %{
                                              pricing_tier: pricing_tier,
                                              product: product
                                            } ->
        pricing_tier
        |> PricingTier.changeset(%{product_id: product.id})
        |> Repo.update()
      end)
      |> Multi.run(:product_sync_item_update, fn _repo,
                                                 %{
                                                   product_sync_item: product_sync_item,
                                                   product: product
                                                 } ->
        product_sync_item
        |> ProductSyncItem.changeset(%{platform_id: product.id})
        |> Repo.update()
      end)

    case Repo.transaction(multi) do
      {:ok, %{product_sync_item: product_sync_item}} ->
        {:ok, product_sync_item}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  @doc """
  Systematically remove all records related to the integration
  based on location_id provided.
  """
  def remove_product_integration(location_id) do
    with {:ok, products} <- get_local_products(location_id),
         {:ok, product_ids} <- {:ok, Enum.map(products, fn lp -> lp.id end)},
         {_num, _nil} <- CampaignProduct.delete_by_product_ids(product_ids),
         {_num, _nil} <- CustomerProduct.delete_all(product_ids),
         {_num, _nil} <- PricingTier.null_all_product_ids(product_ids),
         {_num, _nil} <- Product.null_all_tier_ids(product_ids),
         {_num, _nil} <- Product.delete_all(location_id),
         {_num, _nil} <- PricingTier.delete_all(location_id),
         {_num, _nil} <- ProductSyncItem.delete_by_location(location_id),
         {:ok, _ignore} <- ProductIntegration.delete_by_location(location_id) do
      {:ok, %{success: true}}
    else
      err -> err
    end
  end

  @doc """
  Synchronize the menu items from the remote source to our local database
  tables returning the final list of sync_items for product review.
  """
  def sync_items(location_id) do
    with {:ok, integration} <- ProductIntegration.get_by_location(location_id),
         {:ok, integration} <- has_api_key(integration),
         {:ok, products} <- get_local_products(location_id),
         {:ok, local_items} <- get_local_sync_items(location_id, nil),
         {:ok, remote_items} <- get_remote_sync_items(integration),
         {:ok, _items} <- sync(location_id, products, local_items, remote_items) do
      {:ok, %{success: true}}
    end
  end

  # The first sync occurs when local_products is empty. We clear the products table
  # and import the remote_items.
  defp sync(_location_id, _local_products, [] = _local_items, remote_items) do
    items = Enum.map(remote_items, &ProductSyncItem.create/1)
    # @TODO upload the images to S3 and replace the image paths
    {:ok, items}
  end

  # Subsequent syncs require us to add new items, delete removed items and
  # update existing items who's fields have changed remotely.
  defp sync(location_id, local_products, local_items, remote_items) do
    with {:ok, new} <- sync_new_items(remote_items, local_items),
         {:ok, updated} <- sync_updated_items(local_products, local_items, remote_items),
         {:ok, deleted} <- sync_deleted_items(local_items, remote_items, location_id) do
      {:ok, %{new: new, updated: updated, deleted: deleted}}
    end
  end

  # Return remote_items with an id that is not in our local items id list
  defp sync_new_items(remote_items, local_items) do
    local_ids = Enum.map(local_items, fn i -> i.source_id end)

    items =
      Enum.filter(remote_items, fn i -> Enum.member?(local_ids, i.source_id) == false end)
      |> Enum.map(&ProductSyncItem.create/1)

    # @TODO - we also need to upload the images to S3 here so we should
    # DRY This up as it's also on line #32
    {:ok, items}
  end

  # Return all local items that are not in the remote items list 
  defp sync_deleted_items(local_items, remote_items, location_id) when length(remote_items) > 0 do
    remote_ids = Enum.map(remote_items, fn i -> i.source_id end)
    items = Enum.filter(local_items, fn i -> Enum.member?(remote_ids, i.source_id) == false end)
    source_ids = Enum.map(items, fn i -> i.source_id end)

    platform_ids =
      items
      |> Enum.filter(fn i -> i.platform_id != nil end)
      |> Enum.map(fn i -> i.platform_id end)

    CampaignProduct.delete_by_product_ids(platform_ids)
    CustomerProduct.delete_all(platform_ids)
    ProductSyncItem.delete_all(source_ids, location_id, :source_id)
    PricingTier.delete_all(platform_ids)
    Product.delete_all(platform_ids, :id)
    {:ok, items}
  end

  defp sync_deleted_items(_local_items, _remote_items, _location_id), do: {:ok, []}

  # Items that exist both remotely and locally, synced or not which need to be updated
  # as their data has changed in the remote system.
  defp sync_updated_items(local_products, local_items, remote_items) do
    fields = [:name, :description, :category_id, :type, :image, :in_stock, :prices]

    Enum.each(remote_items, fn ri ->
      case Enum.find(local_items, nil, fn li -> li.source_id == ri.source_id end) do
        nil ->
          nil

        local_item ->
          local_item = Map.from_struct(local_item)
          local_comparable_item = Map.take(local_item, fields)

          remote_comparable_item =
            Enum.filter(ri, fn {key, value} ->
              Enum.member?(fields, key) and value != nil and value != ""
            end)
            |> Enum.into(%{})

          case Map.equal?(local_comparable_item, remote_comparable_item) do
            true ->
              :noop

            false ->
              local_item
              |> Map.merge(remote_comparable_item)
              |> ProductSyncItem.create()
          end

          # update local product associated with local product sync item
          case Enum.find(local_products, nil, fn lp -> lp.id == local_item.platform_id end) do
            nil ->
              nil

            local_product ->
              local_product = Map.from_struct(local_product)
              local_comparable_product = Map.take(local_product, fields)

              remote_comparable_product =
                Enum.filter(ri, fn {key, value} ->
                  Enum.member?(fields, key) and value != nil and value != ""
                end)
                |> Enum.into(%{})
                |> Map.drop([:prices])

              case Map.equal?(local_comparable_product, remote_comparable_product) do
                true ->
                  :noop

                false ->
                  local_product
                  |> Map.merge(remote_comparable_product)
                  |> Product.create()

                  PricingTier.update(Map.merge(%{id: local_product.tier_id}, ri.prices))
              end
          end
      end
    end)

    {:ok, []}
  end

  defp get_remote_sync_items(integration) do
    items =
      case integration.name do
        "xyz" -> Xyz.get_menu(integration.api_key)
        "abc" -> Abc.get_menu(integration)
      end

    items =
      Enum.map(items, fn i ->
        Map.put(i, :product_integration_id, integration.id)
      end)

    {:ok, items}
  end

  defp get_local_sync_items(location_id, options) do
    case ProductSyncItem.get_all(location_id, options) do
      {:error, _error} -> {:error, "Could not get product sync items"}
      {:ok, items} -> {:ok, items}
      items -> {:ok, items}
    end
  end

  defp get_local_products(location_id) do
    case Product.get_all(location_id, nil) do
      {:error, _error} -> {:error, "Could not get local products"}
      [] -> {:ok, []}
      products -> {:ok, products}
    end
  end

  defp has_api_key(integration) do
    case integration.api_key do
      nil -> {:ok, integration.name <> " api key is required"}
      _ -> {:ok, integration}
    end
  end
end
