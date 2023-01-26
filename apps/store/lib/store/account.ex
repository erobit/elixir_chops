defmodule Store.Account do
  alias Ecto.Multi
  alias Store.Account.Email
  alias Store.Account.Schemas.DeleteAccountRequest
  alias Store.Loyalty.{Membership, MembershipLocation}
  alias Store.Customer
  alias Store.Repo

  def send_email_verification(phone, email) do
    Email.send_verification(phone, email)
  end

  def verify_email(phone, email, code) do
    Email.verify(phone, email, code)
  end

  def send_email_recovery(email) do
    Email.send_recovery(email)
  end

  def verify_recovery(old_phone, new_phone, code) do
    Email.verify_recovery(old_phone, new_phone, code)
  end

  # eventually this should be moved to an offline process
  # and we should detach the request from the deletion
  # process as we will potentially also need to remove
  # S3 data in our datalake associated with said customer
  # Writing the value into a table allows us to act on that
  # event downstream
  def delete(customer_id) do
    multi =
      Multi.new()
      |> Multi.run(:delete_request, fn _repo, %{} ->
        %{customer_id: customer_id, processed_date: DateTime.utc_now()}
        |> DeleteAccountRequest.create()
      end)
      |> Multi.run(:delete_customer, fn _repo, %{} ->
        Customer.delete(customer_id)
      end)
      |> Multi.run(:delete_membership_locations, fn _repo, %{} ->
        MembershipLocation.delete(customer_id)
      end)
      |> Multi.run(:delete_memberships, fn _repo, %{} ->
        Membership.delete(customer_id)
      end)
      |> Multi.run(:mark_processed, fn _repo,
                                       %{
                                         delete_request: delete_request
                                       } ->
        DeleteAccountRequest.mark_processed(delete_request.id)
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        {:ok, true}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end
end
