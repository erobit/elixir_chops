defmodule Store.Utility.KeywordListToMap do
  def convert_keyword_list_to_map(obj) do
    for {key, val} <- obj, into: %{}, do: {String.to_atom(key), val}
  end
end
