defmodule PratiBaWeb.AnalyticsView do
  use PratiBaWeb, :view

  alias PratiBa.Formatters.HumanShort
  alias Timex.Duration

  def analytics_indicator(name, value_now, value_before) do
    current_value =
      case name do
        "Average visit duration" ->
          value_now
          |> Duration.from_seconds()
          |> HumanShort.format()

        _ ->
          value_now
      end

    change =
      case value_before do
        0 ->
          ""

        value_before ->
          content_tag(:div, class: "column analytics-indicator-change") do
            [
              arrow(value_before, value_now),
              percentage_change(value_before, value_now)
            ]
          end
      end

    content_tag(:div, class: "column column-25 analytics-indicator") do
      [
        content_tag(:div, class: "row") do
          content_tag(:div, name, class: "column analytics-indicator-name")
        end,
        content_tag(:div, class: "row") do
          [
            content_tag(:div, current_value, class: "column analytics-indicator-current"),
            change
          ]
        end
      ]
    end
  end

  defp arrow(value_before, value_now) do
    {content, klass} =
      if value_before > value_now do
        {"↓", "analytics-indicator-arrow red"}
      else
        {"↑", "analytics-indicator-arrow green"}
      end

    content_tag(:span, content, class: klass)
  end

  defp percentage_change(value_before, value_now) do
    percentage =
      if value_now > value_before do
        value_now / value_before - 1
      else
        1 - value_now / value_before
      end

    percentage =
      (percentage * 100)
      |> round()
      |> abs()
      |> Integer.to_string()

    content_tag(:span, percentage <> "%", class: "analytics-indicator-percentage")
  end
end
