defmodule ConvertUTCDateTime do
  @behaviour Ecto.Type

  def type, do: :utc_datetime

  def cast(%{"time_zone" => time_zone} = map) do
    with {:ok, naive} <- Ecto.Type.cast(:naive_datetime, map),
         {:ok, dt} <- Calendar.DateTime.from_naive(naive, time_zone) do
      {:ok, DateTime.truncate(Calendar.DateTime.shift_zone!(dt, "Etc/UTC"), :second)}
    else
      _ -> :error
    end
  end

  def cast({:ok, datetime, _}), do: cast(datetime)

  def cast(value) when is_binary(value), do: cast(DateTime.from_iso8601(value))

  def cast(value), do: Ecto.Type.cast(:utc_datetime, DateTime.truncate(value, :second))

  def shift(date, timezone) do
    with {:ok, naive} <- Ecto.Type.cast(:naive_datetime, date),
         {:ok, dt} <- Calendar.DateTime.from_naive(naive, "Etc/UTC") do
      {:ok, DateTime.truncate(Calendar.DateTime.shift_zone!(dt, timezone), :second)}
    else
      _ -> :error
    end
  end

  def dump(value), do: Ecto.Type.dump(:utc_datetime, DateTime.truncate(value, :second))

  def load(value), do: Ecto.Type.load(:utc_datetime, DateTime.truncate(value, :second))
end
