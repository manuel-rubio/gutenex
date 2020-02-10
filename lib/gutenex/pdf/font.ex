defmodule Gutenex.PDF.Font do
  # Helpful PDF on fonts in PDFs: http://www.ntg.nl/eurotex/KacvinskyPDF.pdf

  @default_font_size 12
  @default_font "Helvetica"
  @standard_fonts ["Times-Roman", "Times-Italic", "Times-Bold", "Times-BoldItalic",
                    "Helvetica", "Helvetica-Oblique", "Helvetica-Bold", "Helvetica-BoldOblique",
                    "Courier", "Courier-Oblique", "Courier-Bold", "Courier-BoldOblique",
                    "Symbol",
                    "ZapfDingbats"]

  def standard_fonts do
    @standard_fonts
    |> Enum.map(fn x -> {x, font_map(x)} end)
    |> Map.new
  end

  def default_font_size do
    @default_font_size
  end

  def font_map(font_name) do
    %{
      "Encoding" => {:name, "MacRomanEncoding"},
      "Type" => {:name, "Font"},
      "Subtype" => {:name, "Type1"},
      "BaseFont" => {:name, font_name}
    }
  end

  def set_font(%{} = fonts, font_name, font_size \\ @default_font_size) do
    font_name =
      if Map.has_key?(fonts, font_name) do
        font_name
      else
        @default_font
      end

    "/#{font_name} #{font_size} Tf\n"
  end
end
