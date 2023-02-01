defmodule PratiBaWeb.Components.ArticleComponent do
  use PratiBaWeb, :component

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage

  def article(assigns) do
    ~H"""
      <article class="articles relative mt-7 lg:w-[907px] lg:h-[219px] sm:ml-2 sm:h-[120px] border-b-[1px] border-b-[#D9D9D9] dark:border-b-gray-30" id={"article-" <> @article.id}>
        <%= link to: Routes.article_path(@socket, :show, @article), target: "_blank", rel: "noopener" do %>
          <div class={"#{if rem(@index, 2)==1 do "lg:flex-row" else "lg:flex-row-reverse" end} flex"}>
            <.article_image article={@article} />
            <.article_details article={@article} index={@index} socket={@socket}/>
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
    <div class="lg:w-1/3 lg:h-[219px] sm:h-[90px] sm:w-[119px]">
      <%= img_tag(ArticleImage.url({@article.image, @article})) %>
    </div>
    """
  end

  defp article_details(%{} = assigns) do
    ~H"""
    <div class={"#{if rem(@index, 2)==1 do "lg:pl-5" else "lg:pr-5" end} text w-2/3 text-left relative flex flex-col justify-between"}>
      <div class="lg:text-lg sm:text-sm font-bold sm:overflow-hidden sm:pl-2 lg:h-[145px] dark:text-[#D2D5DA]"><h1><%= @article.title %></h1></div>

      <div class="details lg:pt-2 lg:pb-4 text-gray-10 dark:text-gray-20 lg:text-base sm:text-xs sm:pl-2 flex items-center">
        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/link-2.png")} class="pr-2 pr-1 block dark:hidden">
          <img src={Routes.static_path(@socket, "/images/link_dark.png")} class="pr-2 pr-1 dark:block hidden">
          <span class="article-source border-b-[1px] border-b-gray-10 "><%= @article.source.name %></span>
        </span>

        <span class="flex items-center">
          <img class="sm:pr-2 sm:pl-2 pr-1 pl-1" src={Routes.static_path(@socket, "/images/calendar.png")}>
          <.publish_date article={@article} />
        </span>

        <span class="flex items-center">
          <img class="sm:pr-2 sm:pl-2 pr-1 pl-1" src={Routes.static_path(@socket, "/images/clock.png")}>
          <.published article={@article} />
        </span>
      </div>
    </div>
    """
  end

  defp published(%{article: %Article{published_at: published_at}} = assigns) do
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
     <div class="w-full">
        <div class="w-full flex relative items-center justify-center border-b-2 border-b-gray-10 dark:border-b-gray-30">
          <nav role="navigation" class="w-full">
            <section class="w-full flex items-center justify-around">
              <div id="theme-toggle" phx-hook="ToggleBgHook"  class="cursor-pointer">
                <img src={Routes.static_path(@socket, "/images/sun.png")} class="dark:hidden block">
                <img src={Routes.static_path(@socket, "/images/moon.png")} class="dark:block hidden">
              </div>

              <%= link to: Routes.article_index_path(@socket, :index) do %>
                <div>
                  <img src={Routes.static_path(@socket, "/images/logo.png")} class="dark:hidden block lg:py-4 sm:py-2" >
                  <img src={Routes.static_path(@socket, "/images/logo_dark.png")} class="dark:block hidden lg:py-4 sm:py-2">
                </div>
              <% end %>

              <div class="cursor-pointer">
                <img src={Routes.static_path(@socket, "/images/search.png")} class="dark:hidden block cursor-pointer">
                <img src={Routes.static_path(@socket, "/images/search_dark.png")} class="dark:block hidden cursor-pointer">
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
    <h1 class="py-3 lg:block sm:hidden"><%= today %></h1>
    """
  end

  defp sm_screen_date(assigns) do
    {:ok, now_utc} = DateTime.now("Europe/Sarajevo")
    {:ok, today} = Timex.format(now_utc, "%A, %d/%m/%Y", :strftime)

    ~H"""
    <h1 class="py-3 lg:hidden sm:block"><%= today %> </h1>
    """
  end

  defp time(assigns) do
    {:ok, now_utc} = DateTime.now("Europe/Sarajevo")
    {:ok, time} = Timex.format(now_utc, "%H:%M", :strftime)

    ~H"""
     <div class="lg:flex sm:flex items-center pl-2 sm:hidden">
        <img class="pr-2" src={Routes.static_path(@socket, "/images/clock.png")}>
        <h1>
          <%= time %>
        </h1>
      </div>
    """
  end
end
