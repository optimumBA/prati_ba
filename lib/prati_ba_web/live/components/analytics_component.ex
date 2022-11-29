defmodule PratiBaWeb.Components.AnalyticsComponent do
  use PratiBaWeb, :component

  alias PratiBa.Formatters.HumanShort
  alias Timex.Duration

  def analytics_indicator(assigns) do
    ~H"""
    <div class="column column-25 analytics-indicator">
      <div class="row">
        <div class="column analytics-indicator-name"><%= @name %></div>
      </div>

      <div class="row">
        <div class="column analytics-indicator-current"><%= current_value(@name, @value_now) %></div>
        <.change value_before={@value_before} value_now={@value_now} />
      </div>
    </div>
    """
  end

  defp current_value("Average visit duration", value_now) do
    value_now
    |> Duration.from_seconds()
    |> HumanShort.format()
  end

  defp current_value(_name, value_now), do: value_now

  defp change(%{value_before: 0} = assigns) do
    ~H"""

    """
  end

  defp change(assigns) do
    ~H"""
    <div class="column analytics-indicator-change">
      <.arrow value_before={@value_before} value_now={@value_now} />
      <.percentage_change value_before={@value_before} value_now={@value_now} />
    </div>
    """
  end

  defp arrow(%{value_before: value_before, value_now: value_now} = assigns)
       when value_before > value_now do
    ~H"""
    <span class="analytics-indicator-arrow red">↓</span>
    """
  end

  defp arrow(assigns) do
    ~H"""
    <span class="analytics-indicator-arrow green">↑</span>
    """
  end

  defp percentage_change(%{value_before: value_before, value_now: value_now} = assigns) do
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

    assigns = assign(assigns, percentage: percentage)

    ~H"""
    <span class="analytics-indicator-percentage"><%= @percentage <> "%" %></span>
    """
  end
end
