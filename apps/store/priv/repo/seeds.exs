defmodule Store.Seed do
  use Store.Model

  @valid_admin %{role: "sales", is_active: true, password: "password"}
  @valid_employee %{role: "superadmin", is_active: true, password: "password"}

  def generate() do
    seed_base()
    get_seed_data()
    |> Enum.map(&seed_org/1)
  end

  # seed the base tables
  defp seed_base() do
    categories = [
      %{id: 1, name: "a"},
      %{id: 2, name: "b"},
      %{id: 3, name: "c"},
      %{id: 4, name: "d"},
      %{id: 5, name: "e"},
      %{id: 6, name: "f"},
      %{id: 7, name: "g"},
      %{id: 8, name: "h"},
    ]
    categories
    |> Enum.map(&Category.create/1)

    member_groups = [
      %{id: 1, name: "All customers"},
      %{id: 2, name: "Loyal customers"},
      %{id: 3, name: "Casual customers"},
      %{id: 4, name: "Lapsed customers"},
      %{id: 5, name: "One last mile"},
      %{id: 6, name: "Hoarders"},
      %{id: 7, name: "Big spenders"},
      %{id: 8, name: "Top referrals"},
      %{id: 9, name: "Birthday this month"}
    ]
    member_groups
    |> Enum.map(&MemberGroup.create/1)
  end

  defp seed_org(org) do
    {:ok, business} = StoreAdmin.create_business(org.business)

    ids = seed_locations(business.id, org.locations)
    |> location_ids()

    seed_employees(business.id, ids)
    seed_admins()
    seed_app_review_customer()
  end

  defp seed_locations(business_id, locations) do
    locations
    |> Enum.map(fn(location) -> seed_location(business_id, location) end)
  end

  defp location_ids(locations) do
    locations
    |> Enum.map(fn(location) -> location.id end)
  end

  defp seed_location(business_id, location) do
    {:ok, location} = location
    |> Map.put(:business_id, business_id)
    |> Store.create_dispensary
    location
  end

  # @TODO - we should be able to enable/disable customers to prevent them
  # from being able to login - just worried about nefarious activity within
  # system test accounts
  defp seed_app_review_customer() do
    %{
      phone: "11112223333",
      first_name: "App Store",
      last_name: "Reviewer"
    }
    |> Customer.create()
  end

  defp seed_employees(business_id, location_ids) do
    @valid_employee
    |> Map.put(:business_id, business_id)
    |> Map.put(:phone, "11111111111")
    |> Map.put(:email, "superadmin@super.admin")
    |> Map.put(:locations, location_ids)
    |> Store.create_employee
  end

  defp seed_admins() do
    @valid_admin
    |> Map.put(:name, "Admin")
    |> Map.put(:phone, "11111111111")
    |> Map.put(:email, "admin@first.com")
    |> Map.put(:role, "admin")
    |> Map.put(:password, "123admin")
    |> StoreAdmin.create_employee(nil)

    @valid_employee
    |> Map.put(:name, "Super Admin")
    |> Map.put(:phone, "12222223333")
    |> Map.put(:email, "super@second.com")
    |> Map.put(:role, "super")
    |> Map.put(:password, "123super")
    |> StoreAdmin.create_employee(nil)

    @valid_employee
    |> Map.put(:name, "Sales")
    |> Map.put(:phone, "13333333333")
    |> Map.put(:email, "sales@third.co")
    |> Map.put(:role, "sales")
    |> Map.put(:password, "123sales")
    |> StoreAdmin.create_employee(nil)
  end

  def get_seed_data() do
    [%{
      business: %{
        name: "Acme Test Company",
        subdomain: "acme-demo",
        type: "store",
        country: "Canada",
        is_verified: true
      },
      locations: [%{
        name: "Acme Outlet Store",
        address: "123123 Kingsway",
        city: "Vancouver",
        province: "British Columbia",
        postal_code: "VR3 5L3",
        country: "Canada",
        phone: "11111111111",
        website_url: "www.myacme.ca",
        facebook_url: "facebook.com/myacme",
        about: "MyAcme operates with one core mission in mind: keeping compassion other at the heart of everything they do.",
        hero: "https://s3.ca-central-1.amazonaws.com/acme-shops-develop/2/images/hero-1313422314.png",
        logo: "https://s3.ca-central-1.amazonaws.com/acme-shops-develop/2/images/logo-132412341234.png",
        #point: %Geo.Point{coordinates: {17.9570549, 59.4043504}, srid: 4326},
        polygon: %{coordinates: [[[-123.03181715099561, 49.23251421814713],     [-123.03231604187238, 49.23189419807823],     [-123.03103931038129, 49.23160695450467],     [-123.03072280971753, 49.23230053979313],     [-123.03181715099561, 49.23251421814713]]], type: "Polygon"},
        is_active: true,
        service_types: ~w(atm credit debit),
        sms_settings: %{
          provider: "plivo",
          phone_number: "000000000000",   # Acme Low Volume
          max_sms: 10000,
          send_distributed: false,
          distributed_uuid: "",
        }
      }]
    },
    %{
      business: %{
        name: "Acme Demo",
        subdomain: "demo",
        type: "dispensary",
        country: "Canada",
        is_verified: true
      },
      locations: [%{
        name: "Acme - Toronto",
        address: "33 Kensington Ave",
        city: "Toronto",
        province: "Ontario",
        postal_code: "M5T2J8",
        country: "Canada",
        phone: "12222222222",
        website_url: "acme.com",
        facebook_url: "facebook.com/acme2",
        about: "Acme is a Loyalty Rewards Mobile Application",
        hero: "https://s3.ca-central-1.amazonaws.com/acme-shops-develop/2/images/hero-12341234.png",
        logo: "https://s3.ca-central-1.amazonaws.com/acme-shops-develop/2/images/logo-12341234.png",
        #point: %Geo.Point{coordinates: {17.9570549, 59.4043504}, srid: 4326},
        polygon: %{coordinates: [[[-123.03181715099561, 49.23251421814713],     [-123.03231604187238, 49.23189419807823],     [-123.03103931038129, 49.23160695450467],     [-123.03072280971753, 49.23230053979313],     [-123.03181715099561, 49.23251421814713]]], type: "Polygon"},
        is_active: true,
        service_types: ~w(atm credit debit),
        sms_settings: %{
          provider: "plivo",
          phone_number: "22222222222",   # Acme Low Volume
          max_sms: 10000,
          send_distributed: false,
          distributed_uuid: "",
        }
      }]
    }]
  end
end

# Run the seed operation
Store.Seed.generate
