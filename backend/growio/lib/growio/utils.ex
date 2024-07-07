defmodule Growio.Utils do
  def gen_integer(length_range) do
    length_range
    |> Enum.map(fn _ -> Enum.take_random(1..9, 1) |> List.first() |> Integer.to_string() end)
    |> Enum.join()
    |> String.to_integer()
  end

  def naive_utc_now() do
    NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
  end
end
