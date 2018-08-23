defmodule Browser.Helpers do
  @moduledoc false
  def read_file(name) do
    File.read!(Path.expand(name))
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "\t"))
      |> Enum.map(fn [a,b] -> {a, b} end)
  end

  def to_int(str) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> 0
    end
  end
end
