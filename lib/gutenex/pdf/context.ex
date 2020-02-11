defmodule Gutenex.PDF.Context do
  alias Gutenex.PDF.Page.Sizes

  defstruct(
    meta_data: %{
      creator: "Elixir",
      creation_date: :calendar.local_time(),
      producer: "Gutenex",
      author: "",
      title: "",
      subject: "",
      keywords: ""
    },
    images: %{},
    fonts: %{},
    templates: [nil],
    template_aliases: %{},
    pages: [],
    scripts: [],
    convert_mode: "utf8_to_latin2",
    current_page: 1,
    media_box: Sizes.page_size(:letter),
    generation_number: 0
  )
end
