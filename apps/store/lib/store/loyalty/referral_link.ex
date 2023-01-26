defmodule Store.Loyalty.ReferralLink do
  use Store.Model

  @salt "^$3cr3t$@uc3^"

  schema "referral_links" do
    field(:url, :string, virtual: true)
    field(:cipher, :string, virtual: true)
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case get_existing(struct.customer_id, struct.location_id) do
      nil ->
        command = %ReferralLink{} |> changeset(struct)

        case Repo.insert(command) do
          {:ok, link} -> {:ok, link |> put_url()}
          {:error, error} -> {:error, error}
        end

      link ->
        {:ok, link |> put_url()}
    end
  end

  def get_link(cipher) do
    case link_decode(cipher) do
      {:ok, link} -> {:ok, link}
      {:error, error} -> {:error, error}
    end
  end

  defp get_existing(customer_id, location_id) do
    from(l in ReferralLink,
      join: location in assoc(l, :location),
      where: l.customer_id == ^customer_id and l.location_id == ^location_id,
      select: l
    )
    |> preload(:location)
    |> Repo.one()
  end

  defp get(id) do
    query = ReferralLink |> preload(:location)

    case Repo.get(query, id) do
      nil -> {:error, "Link not found"}
      link -> {:ok, link}
    end
  end

  def generate_location_hash(location_id) do
    Hashids.encode(salt(), [location_id])
  end

  def generate_hash(ids) do
    Hashids.encode(salt(), ids)
  end

  defp generate(link) do
    Hashids.encode(salt(), [link.customer_id, link.location_id, link.id])
  end

  defp salt() do
    Hashids.new(
      # using a custom salt helps producing unique cipher text
      salt: @salt,
      # minimum length of the cipher text (1 by default)
      min_len: 4
    )
  end

  def decode(cipher) do
    Hashids.decode(salt(), cipher)
  end

  defp link_decode(cipher) do
    with {:ok, hashids} <- Hashids.decode(salt(), cipher),
         {:ok, link} <- get(Enum.at(hashids, 2, -999_999)) do
      {:ok, link}
    else
      err -> err
    end
  end

  defp put_cipher(link) do
    link
    |> Map.put(:cipher, generate(link))
  end

  defp put_url(link) do
    {:ok, link} = get(link.id)
    link = link |> put_cipher()
    business = Business.get(link.location.business_id)
    url = generate_url(link, business.subdomain)
    link |> Map.put(:url, url)
  end

  defp generate_url(link, subdomain) do
    config = Application.get_env(:store, Store.Referrer)
    prefix = config[:prefix]
    path = config[:path]
    "#{prefix}#{subdomain}.#{path}#{link.cipher}"
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(customer_id location_id)a)
    |> validate_required(~w(customer_id location_id)a)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:location_id)
    |> unique_constraint(:customer_and_location_id,
      name: :referral_links_customer_id_location_id_index
    )
  end
end
