defmodule Store.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Store.Repo

  # without Ecto
  use Store.Model

  def business_factory do
    %Business{
      name: sequence("name"),
      type: "dispensary",
      country: "CA",
      is_verified: true,
      subdomain: sequence("subdomain")
    }
  end

  def customer_factory do
    %Customer{
      first_name: "Ryan",
      last_name: "Lewis",
      phone: "111-111-1111",
      email: "ryan@toke.co",
      avatar: "",
      birthdate: nil,
      categories: [1]
    }
  end

  def employee_factory do
    %Employee{
      business_id: 1,
      phone: "111-111-1111",
      email: "ryan@toke.co",
      password: "ryan",
      role: "owner",
      is_active: true
    }
  end

  def location_factory do
    %Location{
      business_id: 1,
      name: "Holywood Sign",
      address: "4059 Mt Lee Dr",
      city: "Holywood",
      province: "CA",
      country: "USA",
      postal_code: "90068",
      phone: "6474541056",
      website_url: "a",
      facebook_url: "",
      about: "a",
      hero: "hero.jpg",
      logo: "logo.jpg",
      service_types: ["atm", "credit"],
      point: %Geo.Point{coordinates: {17.9570549, 59.4043504}, srid: 4326},
      polygon: %Geo.Polygon{
        coordinates: [[{100.0, 0.0}, {101.0, 0.0}, {101.0, 1.0}, {100.0, 1.0}, {100.0, 0.0}]],
        srid: 4326
      },
      timezone: %{
        id: "America/Vancouver",
        name: "Pacific Standard Time",
        dst_offset: 0,
        raw_offset: -1800
      }
    }
  end

  def reward_factory do
    %Reward{
      business_id: 1,
      categories: [1],
      location_id: 1,
      name: "Birthday",
      type: "birthday",
      points: 7,
      is_active: true
    }
  end

  def referral_factory do
    %Referral{
      business_id: 1,
      location_id: 2,
      from_customer_id: 1,
      recipient_phone: "111-111-1111",
      is_completed: false
    }
  end

  def transaction_factory do
    %Transaction{
      location_id: 1,
      customer_id: 1,
      type: "credit",
      units: 1,
      meta: %{}
    }
  end

  def membership_factory do
    %Membership{
      business_id: 1,
      customer_id: 1
    }
  end

  def membership_location_factory do
    %MembershipLocation{
      membership_id: 1,
      location_id: 1
    }
  end

  def membergroup_factory do
    %MemberGroup{
      name: "Group"
    }
  end

  def category_factory do
    %Category{
      name: "Edibles"
    }
  end

  def deal_factory do
    %Deal{
      business_id: 1,
      location_id: 1,
      categories: [1],
      name: "Test Deal",
      start_time: "20:02:35",
      end_time: "22:02:35",
      is_active: true
    }
  end

  def history_factory do
    %History{
      action: "CheckIn",
      type: "customer",
      meta: %{}
    }
  end
end
