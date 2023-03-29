defmodule PratiBa.Formatters.HumanShort do
  use Timex.Format.Duration.Formatter
  alias Timex.Translator

  @minute 60

  @microsecond 1_000_000

  def format(%Duration{} = duration), do: lformat(duration, Translator.current_locale())
  def format(_), do: {:error, :invalid_timestamp}

  def lformat(%Duration{} = duration, _locale) do
    duration
    |> deconstruct
    |> do_format
  end

  def lformat(_, _locale), do: {:error, :invalid_duration}

  defp do_format(components, str \\ "")

  defp do_format([], str), do: str

  defp do_format([{unit, _} = component | rest], str) do
    cond do
      unit in [:hours, :minutes, :seconds] && String.contains?(str, "T") ->
        do_format(rest, format_component(component, str))

      true ->
        do_format(rest, format_component(component, str))
    end
  end

  defp format_component({_, 0}, str), do: str
  defp format_component({:minutes, m}, str), do: str <> " #{m}m"
  defp format_component({:seconds, s}, str), do: str <> " #{s}s"

  defp deconstruct(duration) do
    micros = Duration.to_microseconds(duration) |> abs
    deconstruct({div(micros, @microsecond), rem(micros, @microsecond)}, [])
  end

  defp deconstruct({0, 0}, components),
    do: Enum.reverse(components)

  defp deconstruct({seconds, us}, components) do
    cond do
      seconds >= @minute ->
        deconstruct({rem(seconds, @minute), us}, [{:minutes, div(seconds, @minute)} | components])

      true ->
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

    cond do
      millis >= 1.0 ->
        deconstruct({0, 0}, [{:seconds, seconds + millis * :math.pow(10, -3)} | components])

      true ->
        deconstruct({0, 0}, [{:seconds, seconds + micro * :math.pow(10, -6)} | components])
    end
  end
end
