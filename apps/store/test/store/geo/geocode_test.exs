defmodule Store.GeocodeTest do
  use Store.Case

  # @valid_zip "90210"
  # @valid_zip_locality %{city: "Beverly Hills", country: "US", state: "CA"}
  # @valid_postal "N2A1K1"
  # @valid_postal_locality %{city: "Kitchener", country: "CA", state: "ON"}
  # @valid_address "281 Woodbridge Ave, L4L 0C6"
  # @valid_york_locality %{country: "CA", state: "ON", city: "Vaughan"}

  # @tag geocoder: "Valid zip"
  # test "geocode a valid zip code" do
  # {:ok, locality} = Geocode.get_locality(@valid_zip)
  # assert locality == @valid_zip_locality
  # end

  # @tag geocoder: "Valid postal code"
  # test "geocode a valid postal code" do
  # {:ok, locality} = Geocode.get_locality(@valid_postal)
  # assert locality == @valid_postal_locality
  # end

  # @tag geocoder: "Valid address"
  # test "geocode a valid addres" do
  # {:ok, locality} = Geocode.get_locality(@valid_address)
  # assert locality == @valid_york_locality
  # end
end
