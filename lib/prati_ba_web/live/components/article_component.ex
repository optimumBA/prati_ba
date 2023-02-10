defmodule PratiBaWeb.Components.ArticleComponent do
  use PratiBaWeb, :component

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage

  def article(assigns) do
    ~H"""
      <article class="group mt-5 sm:w-[907px] sm:h-[230px] ml-2 border-b-[1px] border-b-[#D9D9D9] dark:border-b-gray-30" id={"article-" <> @article.id}>
        <%= link to: Routes.article_path(@socket, :show, @article), target: "_blank", rel: "noopener" do %>
          <div class="flex flex-row sm:group-odd:flex-row-reverse my-3 sm:gap-5">
            <.article_image article={@article} />
            <.article_details article={@article} socket={@socket} />
          </div>
        <% end %>
      </article>
    """
  end

  defp article_image(%{article: %Article{image: nil}} = assigns) do
    ~H"""
    <div class="article-image"></div>
    """
  end

  defp article_image(assigns) do
    ~H"""
      <%= img_tag(ArticleImage.url({@article.image, @article}), class: "sm:w-[302px] sm:h-[215px] h-[96px] w-[119px]") %>
    """
  end

  defp article_details(%{} = assigns) do
    ~H"""
    <div class="text w-2/3 text-left relative flex flex-col justify-between">
      <div class="sm:text-lg text-sm font-bold overflow-hidden pl-2 sm:h-[145px] dark:text-[#D2D5DA]"><h1><%= @article.title %></h1></div>

      <div class="details sm:pt-2 text-gray-10 dark:text-gray-20 sm:text-base text-xs pl-2 flex items-center">
        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/icons/link-2.svg")} class="sm:pr-2 pr-1 block dark:hidden">
          <img src={Routes.static_path(@socket, "/images/icons/link_dark.svg")} class="sm:pr-2 pr-1 dark:block hidden">
          <span class="article-source border-b-[1px] border-b-gray-10 "><%= @article.source.name %></span>
        </span>

        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/icons/calendar.svg")} class="sm:pr-2 sm:pl-2 pr-1 pl-1">
          <.publish_date article={@article} />
        </span>

        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/icons/clock.svg")} class="sm:pr-2 sm:pl-2 pr-1 pl-1">
          <.relative_publish_time article={@article} />
        </span>
      </div>
    </div>
    """
  end

  defp relative_publish_time(%{article: %Article{published_at: published_at}} = assigns) do
    datetime = DateTime.from_naive!(published_at, "Etc/UTC")

    relative_string =
      case Timex.format(datetime, "{relative}", :relative) do
        {:ok, relative_string} ->
          relative_string

        {:error, _} ->
          nil
      end

    ~H"""
    <time class="article-published" datetime={datetime}><%= relative_string %></time>
    """
  end

  defp publish_date(%{article: %Article{published_at: published_at}} = assigns) do
    datetime = DateTime.from_naive!(published_at, "Etc/UTC")

    {:ok, publish_date} = Timex.format(datetime, "%d.%m.%Y", :strftime)

    ~H"""
      <span><%= publish_date%></span>
    """
  end

  def navbar(assigns) do
    ~H"""
     <div class="w-full mt-2">
        <div class="w-full flex relative items-center justify-center border-b-2 border-b-gray-10 dark:border-b-gray-30">
          <nav role="navigation" class="w-full">
            <section class="w-full flex items-center justify-end">
              <div class="sm:w-1/2 w-1/3 sm:pl-[10%] pl-6">
                <div id="theme-toggle" phx-hook="ToggleBgHook"  class="cursor-pointer w-[10%]">
                  <img src={Routes.static_path(@socket, "/images/icons/sun.svg")} class="dark:block hidden">
                  <img src={Routes.static_path(@socket, "/images/icons/moon.svg")} class="dark:hidden block">
                </div>
              </div>
              <div class="w-2/3 sm:pl-3">
                <%= link to: Routes.article_index_path(@socket, :index) do %>
                  <img srcset={Routes.static_path(@socket, "/images/logos/logo_md.png 2x, /images/logos/logo_bg.png 3x")}
                    src={Routes.static_path(@socket, "/images/logos/logo_sm.png")}  width="149" height="64" class="dark:hidden block sm:py-4 py-2">
                  <img srcset={Routes.static_path(@socket, "/images/logos/logo_dark_md.png 2x, /images/logos/logo_dark_bg.png 3x")}
                    src={Routes.static_path(@socket, "/images/logos/logo_dark_sm.png")} width="149" height="64" class="dark:block hidden sm:py-4 py-2">
                <% end %>
              </div>
            </section>
          </nav>
       </div>
       <div class="w-full flex items-center justify-center border-b-2 text-gray-10 border-b-gray-10 dark:border-b-gray-30 dark:text-gray-20">
          <.date />
          <.sm_screen_date />
          <.time socket={@socket} />
        </div>
    </div>
    """
  end

  defp date(assigns) do
    {:ok, now_utc} = DateTime.now("Europe/Sarajevo")
    {:ok, today} = Timex.format(now_utc, "%A, %d.%m.%Y.", :strftime)

    ~H"""
    <h1 class="py-3 sm:block hidden"><%= today %></h1>
    """
  end

  defp sm_screen_date(assigns) do
    {:ok, now_utc} = DateTime.now("Europe/Sarajevo")
    {:ok, today} = Timex.format(now_utc, "%A, %d/%m/%Y", :strftime)

    ~H"""
    <h1 class="py-3 sm:hidden block"><%= today %> </h1>
    """
  end

  defp time(assigns) do
    {:ok, now_utc} = DateTime.now("Europe/Sarajevo")
    {:ok, time} = Timex.format(now_utc, "%H:%M", :strftime)

    ~H"""
    <div class="flex items-center pl-2 hidden sm:flex">
      <img src={Routes.static_path(@socket, "/images/icons/clock.svg")} class="pr-2">
      <%= time %>
    </div>
    """
  end
end
