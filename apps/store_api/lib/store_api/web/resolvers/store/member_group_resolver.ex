defmodule StoreAPI.Resolvers.MemberGroup do
  alias Store

  def get_member_groups(_parent, %{context: %{employee: _employee}}) do
    case Store.get_member_groups() do
      nil -> {:error, "No member groups returned"}
      {:error, error} -> {:error, "Cannot get member groups: #{error}"}
      member_groups -> {:ok, member_groups}
    end
  end
end
