defmodule Store.Utility.DateRange do
  # note: this module should not be used for timezone edge conditions due to UTC issues with Timex.now
  def get(:today) do
    start = Timex.beginning_of_day(Timex.now())
    finish = Timex.end_of_day(start)
    %{start: start, finish: finish}
  end

  def get(:this_week) do
    start = Timex.beginning_of_week(Timex.now())
    finish = Timex.end_of_week(start)
    %{start: start, finish: finish}
  end

  def get(:this_month) do
    start_of_month = Timex.beginning_of_month(Timex.now())
    end_of_month = Timex.end_of_month(start_of_month)
    %{start: start_of_month, finish: end_of_month}
  end

  def get(:this_year) do
    start_of_year = Timex.beginning_of_year(Timex.now())
    end_of_year = Timex.end_of_year(start_of_year)
    %{start: start_of_year, finish: end_of_year}
  end

  def get(:total) do
    %{start: Timex.to_datetime(Timex.epoch()), finish: Timex.now()}
  end
end
