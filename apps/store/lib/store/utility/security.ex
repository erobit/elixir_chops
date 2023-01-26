defmodule Store.Utility.Security do
  import ZXCVBN

  def check_password_strength(password) do
    case zxcvbn(password) do
      :error -> {:error, "password_required"}
      %{score: 0} -> {:error, %{score: 0, message: "weakest_password"}}
      %{score: 1} -> {:error, %{score: 1, message: "weak_password"}}
      %{score: 2} -> {:ok, %{score: 2, message: "moderate_password"}}
      %{score: 3} -> {:ok, %{score: 3, message: "strong_password"}}
      %{score: 4} -> {:ok, %{score: 4, message: "strongest_password"}}
    end
  end
end
