defmodule Neopixel.Animate do
  alias Nerves.Neopixel

  # == Rainbow Pattern ==
  def rainbow(ch, pixels, opts \\ []) do
    delay = opts[:delay] || 100
    red        = {255,   0,   0, 0}
    orange     = {255, 127,   0, 127}
    yellow     = {255, 255,   0, 255}
    green      = {0,   255,   0, 127}
    light_blue = {0,   255, 255, 0}
    blue       = {0,     0, 255, 127}
    purple     = {127,   0, 127, 255}
    pink       = {255,   0, 127, 127}
    data = [red, orange, yellow, green, light_blue, blue, purple, pink]
           |> List.duplicate(rem(pixels, 8) + 1)
           |> List.flatten
           |> Enum.slice(0, pixels)
    spawn fn () -> spin_indef(ch, data, delay) end
  end

  # == Spinner Pattern ==
  def spinner(ch, pixels, opts \\ []) do
    color = opts[:color] || {255, 0, 0, 127}
    delay = opts[:delay] || 100
    data = [color, color, color] ++ List.duplicate({0, 0, 0, 0}, pixels-3)

    spawn fn () -> spin_indef(ch, data, delay) end
  end

  def spin_indef(ch, data, delay) do
    Neopixel.render ch, {125, data}
    [h | t] = data
    :timer.sleep(delay)
    spin_indef(ch, t ++ [h], delay)
  end

  # == Pulse Pattern ==
  def pulse(ch, pixels, opts \\ []) do
    color = opts[:color] || {212, 175, 55, 127}
    delay = opts[:delay] || 100

    data = List.duplicate(color, pixels)
    spawn fn () -> pulse_indef(ch, data, 0, :up) end
  end

  def pulse_indef(ch, data, 0, :down) do
    pulse_indef(ch, data, 1, :up)
  end

  def pulse_indef(ch, data, 125, :up) do
    pulse_indef(ch, data, 124, :down)
  end

  def pulse_indef(ch, data, brightness, direction) do
    Neopixel.render ch, {brightness, data}
    :timer.sleep(5)
    brightness =
      if direction == :up, do: brightness + 1, else: brightness - 1
    pulse_indef(ch, data, brightness, direction)
  end
end
