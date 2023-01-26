defmodule Store.Utility.QueryMacros do
  defmacro within_today(date_field, timezone_field) do
    quote do
      fragment(
        "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
        unquote(date_field),
        unquote(timezone_field),
        unquote(timezone_field),
        unquote(timezone_field)
      )
    end
  end

  defmacro within_this_week(date_field, timezone_field) do
    quote do
      fragment(
        "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
        unquote(date_field),
        unquote(timezone_field),
        unquote(timezone_field),
        unquote(timezone_field)
      )
    end
  end

  defmacro within_this_month(date_field, timezone_field) do
    quote do
      fragment(
        "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
        unquote(date_field),
        unquote(timezone_field),
        unquote(timezone_field),
        unquote(timezone_field)
      )
    end
  end

  defmacro within_this_year(date_field, timezone_field) do
    quote do
      fragment(
        "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
        unquote(date_field),
        unquote(timezone_field),
        unquote(timezone_field),
        unquote(timezone_field)
      )
    end
  end

  defmacro all_time(date_field, timezone_field) do
    quote do
      fragment(
        "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
        unquote(date_field),
        unquote(timezone_field),
        unquote(timezone_field),
        unquote(timezone_field)
      )
    end
  end

  defmacro greater_or_equal(field, start) do
    quote do
      fragment("? >= (?) :: timestamp", unquote(field), unquote(start))
    end
  end
end
