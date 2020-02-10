defmodule Gutenex do
  use GenServer
  alias Gutenex.PDF
  alias Gutenex.PDF.Text
  alias Gutenex.PDF.Font
  alias Gutenex.PDF.Geometry

  #######################
  ##       Setup       ##
  #######################

  @doc """
  Starts the PDF generation server.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Returns the default context and stream (empty binary)
  """
  def init(:ok) do
    {:ok, [%Gutenex.PDF.Context{}, <<>>]}
  end

  #######################
  ##    Client API     ##
  #######################

  @doc """
  Stop the server process
  """
  def stop(pid) do
    GenServer.stop(pid)
  end

  @doc """
  Returns the current context
  """
  def context(pid) do
    GenServer.call(pid, :context)
  end

  @doc """
  Sets the current context
  """
  def context(pid, new_context) do
    GenServer.cast(pid, {:context, new_context})
    pid
  end

  @doc """
  Sets the current page
  """
  def set_page(pid, page) when is_integer(page) do
    GenServer.cast(pid, {:context, :put, {:current_page, page}})
    pid
  end

  @doc """
  Begin a text block
  """
  def begin_text(pid) do
    GenServer.cast(pid, {:text, :begin})
    pid
  end

  @doc """
  Set the text position
  """
  def text_position(pid, x_coordinate, y_coordinate) do
    GenServer.cast(pid, {:text, :position, {x_coordinate, y_coordinate}})
    pid
  end

  @doc """
  Set the text render mode
  """
  def text_render_mode(pid, render_mode) do
    GenServer.cast(pid, {:text, :render_mode, render_mode})
    pid
  end

  @doc """
  Write text to the stream
  """
  def write_text(pid, text_to_write) do
    GenServer.cast(pid, {:text, :write, text_to_write})
    pid
  end

  @doc """
  Write text more break line to the stream
  """
  def write_text_br(pid, text_to_write) do
    GenServer.cast(pid, {:text, :write_br, text_to_write})
    pid
  end

  @doc """
  Set line space
  """
  def text_leading(pid, size) do
    GenServer.cast(pid, {:text, :line_spacing, size})
    pid
  end

  @doc """
  End a text block
  """
  def end_text(pid) do
    GenServer.cast(pid, {:text, :end})
    pid
  end

  #####################################
  #               Fonts               #
  #####################################

  @doc """
  Set the font
  """
  def set_font(pid, font_name) do
    GenServer.cast(pid, {:font, :set, font_name})
    pid
  end

  @doc """
  Set the font and font size
  """
  def set_font(pid, font_name, font_size) do
    GenServer.cast(pid, {:font, :set, {font_name, font_size}})
    pid
  end

  @doc """
  Gets the current stream
  """
  def stream(pid) do
    GenServer.call(pid, :stream)
  end

  @doc """
  Append to the current stream
  """
  def append_to_stream(pid, content) do
    GenServer.cast(pid, {:stream, :append, content})
    pid
  end

  @doc """
  Export the PDF document to a binary
  """
  def export(pid) do
    GenServer.call(pid, :export)
  end

  def export(pid, file_name) do
    File.write(file_name, export(pid))
    pid
  end

  #####################################
  #              Images               #
  #####################################

  def add_image(pid, image_alias, %Imagineer.Image.PNG{} = image) do
    GenServer.cast(pid, {:image, :add, {image_alias, image}})
    pid
  end

  @doc """
  Add an image by alias
  """
  def draw_image(pid, image_alias) do
    draw_image(pid, image_alias, %{})
  end

  def draw_image(pid, image_alias, options) do
    GenServer.cast(pid, {:image, :write, {image_alias, options}})
    pid
  end

  #####################################
  #            Templates              #
  #####################################

  def add_template(pid, template_alias, template_contents) do
    GenServer.cast(pid, {:templates, :add, {template_alias, template_contents}})
    pid
  end

  def set_template(pid, template_alias) do
    GenServer.cast(pid, {:template, :set, {template_alias}})
    pid
  end

  #######################
  ##      Geometry     ##
  #######################

  def move_to(pid, point_x, point_y)
      when is_integer(point_x) and is_integer(point_y) do
    move_to(pid, {point_x, point_y})
  end

  def move_to(pid, {point_x, point_y} = point)
      when is_integer(point_x) and is_integer(point_y) do
    GenServer.cast(pid, {:geometry, :move_to, point})
    pid
  end

  #######################
  ##   Call handlers   ##
  #######################

  @doc """
  Returns the current context
  """
  def handle_call(:context, _from, [context, stream]) do
    {:reply, context, [context, stream]}
  end

  @doc """
  Returns the stream
  """
  def handle_call(:stream, _from, [context, stream]) do
    {:reply, stream, [context, stream]}
  end

  @doc """
  Export the PDF to binary format
  """

  def handle_call(:export, _from, [context, stream]) do
    {:reply, PDF.export(context, stream), [context, stream]}
  end

  #######################
  ##   Cast handlers   ##
  #######################

  @doc """
  Sets the current context
  """
  def handle_cast({:context, new_context}, [_context, stream]) do
    {:noreply, [new_context, stream]}
  end

  @doc """
  Appends to the stream
  """
  def handle_cast({:stream, :append, str}, [context, stream]) do
    new_stream = stream <> str
    {:noreply, [context, new_stream]}
  end

  @doc """
  Sets the current page
  """
  def handle_cast({:context, :put, {key, value}}, [context, stream]) do
    new_context = Map.put(context, key, value)
    {:noreply, [new_context, stream]}
  end

  @doc """
    Begin a section of text
  """
  def handle_cast({:text, :begin}, [context, stream]) do
    stream = stream <> Text.begin_text()
    {:noreply, [context, stream]}
  end

  @doc """
    End a section of text
  """
  def handle_cast({:text, :end}, [context, stream]) do
    stream = stream <> Text.end_text()
    {:noreply, [context, stream]}
  end

  @doc """
    Write some text!
  """
  def handle_cast({:text, :write, text_to_write}, [context, stream]) do
    stream = stream <> Text.write_text(text_to_write)
    {:noreply, [context, stream]}
  end

  @doc """
    Write some text more break line!
  """
  def handle_cast({:text, :write_br, text_to_write}, [context, stream]) do
    stream = stream <> Text.write_text_br(text_to_write)
    {:noreply, [context, stream]}
  end

  @doc """
    Set line space
  """
  def handle_cast({:text, :line_spacing, size}, [context, stream]) do
    stream = stream <> Text.line_spacing(size)
    {:noreply, [context, stream]}
  end

  @doc """
    Set the text position
  """
  def handle_cast({:text, :position, {x_coordinate, y_coordinate}}, [
        context,
        stream
      ]) do
    stream = stream <> Text.text_position(x_coordinate, y_coordinate)
    {:noreply, [context, stream]}
  end

  @doc """
    Set the text render mode
  """
  def handle_cast({:text, :render_mode, render_mode}, [context, stream]) do
    stream = stream <> Text.render_mode(render_mode)
    {:noreply, [context, stream]}
  end

  #####################################
  #            Templates              #
  #####################################

  def handle_cast({:templates, :add, {template_alias, template_contents}}, [
        context,
        stream
      ]) do
    template_aliases =
      Map.put(context.template_aliases, template_alias, template_contents)

    {:noreply,
     [%Gutenex.PDF.Context{template_aliases: template_aliases}, stream]}
  end

  def handle_cast({:template, :set, {template_alias}}, [context, stream]) do
    templates =
      List.replace_at(
        context.templates,
        context.current_page - 1,
        template_alias
      )

    {:noreply, [%Gutenex.PDF.Context{context | templates: templates}, stream]}
  end

  #####################################
  #              Images               #
  #####################################

  def handle_cast({:image, :add, {image_alias, image}}, [context, stream]) do
    images = Map.put(context.images, image_alias, image)
    {:noreply, [%Gutenex.PDF.Context{context | images: images}, stream]}
  end

  def handle_cast({:image, :write, {image_alias, options}}, [context, stream]) do
    image = Map.get(context.images, image_alias)
    stream = stream <> Gutenex.PDF.Images.set_image(image_alias, image, options)
    {:noreply, [context, stream]}
  end

  #####################################
  #               Fonts               #
  #####################################

  @doc """
    Set the font and size
  """
  def handle_cast({:font, :set, {font_name, font_size}}, [context, stream]) do
    stream = stream <> Font.set_font(context.fonts, font_name, font_size)

    # Add the font to the current context... yeah this is additive... but meh
    new_fonts = Map.put_new(context.fonts, font_name, Font.font_map(font_name))
    context = Map.put(context, :fonts, new_fonts)

    {:noreply, [context, stream]}
  end

  @doc """
    Set the font
  """
  def handle_cast({:font, :set, font_name}, [context, stream]) do
    stream = stream <> Font.set_font(context.fonts, font_name)

    # Add the font to the current context... yeah this is additive... but meh
    new_fonts = Map.put_new(context.fonts, font_name, Font.font_map(font_name))
    context = Map.put(context, :fonts, new_fonts)

    {:noreply, [context, stream]}
  end

  #####################################
  #             Geometry              #
  #####################################

  def handle_cast({:geometry, :move_to, {point_x, point_y}}, [context, stream]) do
    stream = stream <> Geometry.move_to({point_x, point_y})
    {:noreply, [context, stream]}
  end
end
