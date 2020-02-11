# Gutenex

[![Build Status](https://travis-ci.org/SenecaSystems/gutenex.svg?branch=master)](https://travis-ci.org/SenecaSystems/gutenex)

PDF generation!

> So weird that it's still a thing for murderers in horror movies to keep clippings of their crimes. PDF that shit!
> — [Julieanne Smolinkski](https://twitter.com/BoobsRadley)

What started out as a wrapper for the Erlang [erlguten](https://github.com/ztmr/erlguten) library has turned into a full rewrite in Elixir.

## Plan

Rewriting the basic PDF functionality means:

* [x] text
* [x] fonts
* [x] images
* [x] rendering/exporting
* [ ] parsing existing PDFs
* [ ] templating
* [ ] documentation

# Usage

```elixir
  # Load image, get alias
  {alpaca_alias, alpaca_rendition} = Gutenex.PDF.Images.load("test/support/images/alpaca.png")

  File.mkdir "tmp"
  {:ok, pid} = Gutenex.start_link()
  Gutenex.add_image(pid, alpaca_alias, alpaca_rendition)
  v() |> Gutenex.begin_text()
  v() |> Gutenex.set_font("Helvetica", 48)
  v() |> Gutenex.text_position(40, 180)
  v() |> Gutenex.text_render_mode(:fill)
  v() |> Gutenex.write_text("ABC")
  v() |> Gutenex.set_font("Courier", 32)
  v() |> Gutenex.text_render_mode(:stroke)
  v() |> Gutenex.write_text("xyz")
  v() |> Gutenex.end_text()
  v() |> Gutenex.move_to(400, 20)
  v() |> Gutenex.draw_image(alpaca_alias, %{translate_x: 300, translate_y: 500})
  v() |> Gutenex.export("tmp/alpaca.pdf")
  Gutenex.stop(pid)
```

Now open up that file and you should see some text near the bottom and a picture
of what I believe to be an alpaca. Could also be a llama.

By default, coordinates are in units of 1/72 inch as per the PDF
spec. Origin is in lower left corner of the page. This is roughly 1
point in printing terms.

```
  Gutenex.line_width(pid, 0.01)          # very fine line
  |> Gutenex.line({{0, 0}, {500, 500}})  # up and to the right
```
