defmodule Gutenex.PDF.Utils do
  def escape(string) do
    string
    |> String.replace("(", "\\(")
    |> String.replace(")", "\\)")
    |> String.replace("||", "\\\\")
  end
end
