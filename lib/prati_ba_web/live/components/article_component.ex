defmodule PratiBaWeb.Components.ArticleComponent do
  use PratiBaWeb, :component

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage

  def article(assigns) do
    ~H"""
      <article id={"article-" <> @article.id} class="group my-3 lg:h-[230px] duration-200">
        <%= link to: Routes.article_path(@socket, :show, @article), target: "_blank", rel: "noopener" do %>
          <div class="w-full flex flex-row sm:group-odd:flex-row-reverse sm:gap-5">
            <.article_image article={@article} />
            <.article_details article={@article} socket={@socket} />
          </div>
        <% end %>
        <hr class="sm:w-11/12 sm:float-right my-3 border-gray-300 dark:border-gray-30" />
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
    <div class="w-1/4 h-20 sm:h-32 md:min-w-[220px] lg:min-w-[302px] lg:h-[215px]">
      <%= img_tag(ArticleImage.url({@article.image, @article}),
        class: "w-full h-full object-cover rounded-md")
      %>
    </div>
    """
  end

  defp article_details(%{} = assigns) do
    ~H"""
    <div class="w-3/4 text-left relative flex flex-col justify-between">
      <div class="text-sm sm:text-[20px] lg:text-lg font-semibold lg:font-medium overflow-hidden leading-tight pl-2 lg:min-h-[145px] dark:text-gray-300"><h1><%= @article.title %></h1></div>

      <div class="flex items-center details pt-1 sm:pt-2 text-gray-10 dark:text-gray-20 text-xs sm:text-sm lg:text-base pl-2">
        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/icons/link-2.svg")} class="sm:pr-2 pr-1 block dark:hidden">
          <img src={Routes.static_path(@socket, "/images/icons/link_dark.svg")} class="sm:pr-2 pr-1 dark:block hidden">
          <span class="article-source border-b text-center border-b-gray-10"><%= @article.source.name %></span>
        </span>

        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/icons/calendar.svg")} class="sm:pr-2 sm:pl-2 pr-1 pl-1">
          <.publish_date article={@article} />
        </span>

        <span class="flex items-center">
          <img src={Routes.static_path(@socket, "/images/icons/clock.svg")} class="w-3 sm:w-5 sm:mx-2 mx-1">
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
        <div class="w-full fixed top-0 flex items-center justify-center bg-white dark:bg-[#212936] z-50 border-b border-gray-10 dark:border-gray-30">
          <nav id="navbar" role="navigation" class="w-full flex items-center md:w-10/12 xl:w-[907px]">
              <section class="w-full">
                <div id="theme-toggle" class="ml-6 cursor-pointer w-max text-gray-600 dark:text-gray-20" phx-hook="ToggleBgHook">
                  <img src={Routes.static_path(@socket, "/images/icons/sun.svg")} class="dark:block hidden">
                  <img src={Routes.static_path(@socket, "/images/icons/moon.svg")} class="dark:hidden block">
                  </div>
              </section>
              <section class="w-max pt-2">
                <%= link to: Routes.article_index_path(@socket, :index), class: "block w-max mx-auto" do %>
                  <img id="app-logo" srcset={Routes.static_path(@socket, "/images/logos/logo_md.png 2x, /images/logos/logo_bg.png 3x")}
                    src={Routes.static_path(@socket, "/images/logos/logo_sm.png")} width="149" height="64" class="w-24 sm:w-36 dark:hidden block sm:py-4 py-2 duration-200">
                  <img id="app-logo-dark" srcset={Routes.static_path(@socket, "/images/logos/logo_dark_md.png 2x, /images/logos/logo_dark_bg.png 3x")}
                    src={Routes.static_path(@socket, "/images/logos/logo_dark_sm.png")} width="149" height="64" class="w-24 sm:w-36 dark:block hidden sm:py-4 py-2 duration-200">
                <% end %>
              </section>
              <section class="w-full"></section>
          </nav>
       </div>
       <div class="w-full flex mt-[66px] sm:mt-[102px] font-thin sm:font-normal text-sm sm:text-base items-center justify-center border-b text-gray-600 sm:text-gray-10 border-gray-10 dark:border-gray-30 dark:text-gray-20">
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

  def new_articles_indicator(assigns) do
    ~H"""
    <div class="w-full flex items-center justify-center mt-6">
      <div id="indicator" phx-click="refresh_articles" class="sm:px-16 dark:text-white text-[#505050] bg-[#C0EB3C] rounded-xl px-24 py-1 cursor-pointer">Nove vijesti</div>
    </div>
    """
  end
end
