defmodule PratiBa.Formatters.HumanShort do
  @moduledoc false

  use Timex.Format.Duration.Formatter
  alias Timex.Translator

  @minute 60

  @microsecond 1_000_000

  @spec format(Duration.t()) :: String.t() | {:error, :invalid_timestamp}
  def format(%Duration{} = duration), do: lformat(duration, Translator.current_locale())
  def format(_duration), do: {:error, :invalid_timestamp}

  @spec lformat(Duration.t(), String.t()) :: String.t() | {:error, :invalid_duration}
  def lformat(%Duration{} = duration, _locale) do
    duration
    |> deconstruct()
    |> do_format()
  end

  def lformat(_duration, _locale), do: {:error, :invalid_duration}

  defp do_format(components, str \\ "")

  defp do_format([], str), do: str

  defp do_format([{unit, _other} = component | rest], str) do
    if unit in [:hours, :minutes, :seconds] && String.contains?(str, "T") do
      do_format(rest, format_component(component, str))
    else
      do_format(rest, format_component(component, str))
    end
  end

  defp format_component({_unit, 0}, str), do: str
  defp format_component({:minutes, m}, str), do: str <> " #{m}m"
  defp format_component({:seconds, s}, str), do: str <> " #{s}s"

  defp deconstruct(duration) do
    micros =
      duration
      |> Duration.to_microseconds()
      |> abs()

    deconstruct({div(micros, @microsecond), rem(micros, @microsecond)}, [])
  end

  defp deconstruct({0, 0}, components),
    do: Enum.reverse(components)

  defp deconstruct({seconds, us}, components) do
    if seconds >= @minute do
      deconstruct({rem(seconds, @minute), us}, [{:minutes, div(seconds, @minute)} | components])
    else
      get_fractional_seconds(seconds, us, components)
    end
  end

  defp get_fractional_seconds(seconds, 0, components),
    do: deconstruct({0, 0}, [{:seconds, seconds} | components])

  defp get_fractional_seconds(seconds, micro, components) do
    millis =
      micro
      |> Duration.from_microseconds()
      |> Duration.to_milliseconds()

    if millis >= 1.0 do
      deconstruct({0, 0}, [{:seconds, seconds + millis * :math.pow(10, -3)} | components])
    else
      deconstruct({0, 0}, [{:seconds, seconds + micro * :math.pow(10, -6)} | components])
    end
  end
end
