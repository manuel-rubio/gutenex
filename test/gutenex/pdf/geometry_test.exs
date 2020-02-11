defmodule Gutenex.PDF.GeometryTest do
  use ExUnit.Case, async: true
  alias Gutenex.PDF.Geometry

  test "#move_to should move to a point" do
    assert Geometry.move_to({20, 40}) == "20 40 m\n"
  end
end
