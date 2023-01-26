defmodule StoreAPI.Web.BusinessTest do
  use Store.Case
  use StoreAPI.Web.ConnCase
  import StoreAPI.Web.GraphqlHelpers

  @valid_business params_for(:business)

  test "getting a single business by ID" do
    query = """
    {
      business {
        id
        type
      }
    }
    """

    res =
      get_conn(:authorized)
      |> post("/crm", query_skeleton(query, "GetBusiness"))

    {business_id, ""} = res |> get_req_header("business_id") |> List.first() |> Integer.parse()
    assert json_response(res, 200)["data"]["business"]["id"] == business_id
  end

  test "get business by id" do
    {:ok, business} = StoreAdmin.create_business(@valid_business)

    query = """
    {
      business(id: #{business.id}) {
        id
      }
    }
    """

    res =
      get_conn(:admin_authorized)
      |> post("/admin", query_skeleton(query, ""))

    assert json_response(res, 200)["data"]["business"]["id"] == business.id
  end

  test "get all businesses" do
    query = """
    query businesses($options: Options!) {
      businesses(options: $options) {
        entries {
          id
          type
          name
          subdomain
          country
          is_verified
          is_active
          __typename
        }
        page_number
        page_size
        total_entries
        total_pages
        __typename
      }
    }
    """

    variables = %{"options" => %{"filters" => [], "page" => %{"limit" => 50, "offset" => 1}}}

    res =
      get_conn(:admin_authorized)
      |> post("/admin", query_raw(query, variables))

    assert length(json_response(res, 200)["data"]["businesses"]["entries"]) > 0
  end
end
