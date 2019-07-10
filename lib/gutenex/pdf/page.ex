defmodule Gutenex.PDF.Page do
  def to_pdf(parent_reference, contents_reference, generation_number, options \\ %{}) do
    {
      :dict,
      [
        {"Type", {:name, "Page"}},
        {"Parent", {:ptr, parent_reference, generation_number}},
        {"Contents", {:ptr, contents_reference, generation_number}}
        | Enum.map(options, &page_option(&1))
      ]
    }
  end

  defp page_option({key, value}) do
    atom_to_page_key(key)
    |> page_option(value)
  end

  defp page_option("LastModified", value) do
    {"LastModified", {:date, value}}
  end

  defp page_option(key, value) do
    {key, value}
  end

  defp atom_to_page_key(:last_modified), do: "LastModified"
  defp atom_to_page_key(:resources), do: "Resources"
  defp atom_to_page_key(:annotations), do: "Annots"
  defp atom_to_page_key(anything), do: anything
end
