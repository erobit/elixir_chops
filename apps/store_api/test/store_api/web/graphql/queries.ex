defmodule StoreAPI.Graphql.Queries do
  @locations """
    query LOCATIONS_QUERY {
      locations {
        name
        city
        phone
        website_url
      }
    }
  """

  @location_names = """
    query LOCATION_NAMES_QUERY {
      locations {
        id
        name
      }
    }
  """

  @employees """
    query EMPLOYEES_QUERY {
      employees {
        id
        email
        phone
        role
        is_active
        locations {
          name
        }
      }
    }
  """

  def locations, do: @locations_query
  def location_names, do: @location_names
  def employees, do: @employees
end
