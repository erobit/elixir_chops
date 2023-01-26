defmodule GoogleGeocodingApiException do
  defexception message: "An error has occurred in your Google Geocoding API request"
end

defmodule GoogleTimezoneApiException do
  defexception message: "An error has occurred in your Google Timezone API request"
end

defmodule FreeGeoIpApiException do
  defexception message: "An error has occurred in your FreeGeoIp API request"
end
