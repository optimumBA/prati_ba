defmodule PratiBaWeb.Components.ArticleComponent do
  use PratiBaWeb, :component

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage
  alias PratiBaWeb.Components.Icons

  def article(assigns) do
    ~H"""
      <article id={"article-" <> @article.id} class="group my-3 lg:h-[230px] duration-200">
        <.link href={~p"/#{@article}"} class="article" target="_blank" rel="noopener">
          <div class="w-full flex flex-row sm:group-odd:flex-row-reverse sm:gap-5">
            <.article_image article={@article} />
            <.article_details article={@article} socket={@socket} />
          </div>
        </.link>
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

  defp article_details(assigns) do
    ~H"""
    <div class="w-3/4 text-left relative flex flex-col justify-between">
      <div class="text-sm sm:text-[20px] lg:text-lg font-semibold lg:font-medium overflow-hidden leading-tight pl-2 lg:min-h-[145px] dark:text-gray-300"><h1><%= @article.title %></h1></div>

      <div class="flex items-center details pt-1 sm:pt-2 text-gray-10 dark:text-gray-20 text-xs sm:text-sm lg:text-base pl-2">
        <span class="flex items-center">
          <Icons.article_link />
          <span class="article-source border-b text-center border-b-gray-10"><%= @article.source.name %></span>
        </span>

        <span class="flex items-center">
          <img src={~p"/images/icons/calendar.svg"} class="w-5 sm:w-8 px-1 sm:px-2">
          <div class="block sm:hidden"><.publish_date article={@article} format={"%d/%m/%Y"}/></div>
          <div class="hidden sm:block"><.publish_date article={@article} format={"%d.%m.%Y"} /></div>
        </span>

        <span class="flex items-center">
          <img src={~p"/images/icons/clock.svg"} class="w-3 sm:w-5 sm:mx-2 mx-1">
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

        {:error, _term} ->
          nil
      end

    assigns = assign(assigns, datetime: datetime, relative_string: relative_string)

    ~H"""
    <time class="block sm:hidden article-published truncate overflow-hidden" datetime={@datetime}><%= short_relative_publish_time(@relative_string) %></time>
    <time class="hidden sm:block article-published truncate overflow-hidden" datetime={@datetime}><%= @relative_string %></time>
    """
  end

  defp publish_date(%{article: %Article{published_at: published_at}, format: format} = assigns) do
    datetime = DateTime.from_naive!(published_at, "Etc/UTC")
    {:ok, publish_date} = Timex.format(datetime, format, :strftime)

    assigns = assign(assigns, :publish_date, publish_date)

    ~H"""
      <span><%= @publish_date %></span>
    """
  end

  def navbar(assigns) do
    ~H"""
     <div id="nav-ignore" class="w-full" phx-update="ignore">
        <div id="nav-hook" class="w-full fixed top-0 flex items-center justify-center bg-white dark:bg-[#212936] z-50 border-b border-gray-10 dark:border-gray-30"
          phx-hook="HeaderHook"
        >
          <nav id="navbar" role="navigation" class="w-full flex items-center md:w-10/12 xl:w-[907px]">
              <section class="w-full">
                <div id="theme-toggle" class="ml-6 cursor-pointer w-max text-gray-600 dark:text-gray-20" phx-hook="ToggleBgHook">
                  <div class="dark:block hidden"><Icons.sun /></div>
                  <div class="dark:hidden block"><Icons.moon /></div>
                </div>
              </section>
              <section class="w-max pt-2">
                <.link href={~p"/"} class="block w-max mx-auto">
                  <img id="app-logo" srcset={~p"/images/logos/logo_md.png 2x, /images/logos/logo_bg.png 3x"}
                    src={~p"/images/logos/logo_sm.png"} width="149" height="64" class="w-24 sm:w-36 dark:hidden block sm:py-4 py-2 duration-200">
                  <img id="app-logo-dark" srcset={~p"/images/logos/logo_dark_md.png 2x, /images/logos/logo_dark_lg.png 3x"}
                    src={~p"/images/logos/logo_dark_sm.png"} width="149" height="64" class="w-24 sm:w-36 dark:block hidden sm:py-4 py-2 duration-200">
                </.link>
              </section>
              <section class="w-full"></section>
          </nav>
       </div>
       <div class="w-full flex mt-[66px] sm:mt-[102px] font-thin sm:font-normal text-sm sm:text-base items-center justify-center border-b text-gray-600 sm:text-gray-10 border-gray-10 dark:border-gray-30 dark:text-gray-20">
          <div class="sm:block hidden"><.current_date format={"%A, %d.%m.%Y"} /></div>
          <div class="sm:hidden block"><.current_date format={"%A, %d/%m/%Y"} /></div>
          <.time socket={@socket} />
        </div>
    </div>
    """
  end

  defp current_date(%{format: format} = assigns) do
    {:ok, now_utc} = DateTime.now("Europe/Sarajevo")
    {:ok, today} = Timex.format(now_utc, format, :strftime)

    assigns = assign(assigns, :today, today)

    ~H"""
    <h1 id="current_date" class="py-2 sm:py-3 capitalize"><%= @today %></h1>
    """
  end

  defp time(assigns) do
    ~H"""
    <div id="time" class="flex items-center pl-2 hidden sm:flex" phx-hook="DisplayTimeHook">
      <img src={~p"/images/icons/clock.svg"} class="mr-2">
      <span id="current_time"></span>
    </div>
    """
  end

  def new_articles_indicator(assigns) do
    ~H"""
    <div class="mx-4 flex items-center justify-center mt-6">
      <div
        id="indicator"
        class="w-full sm:w-max sm:px-16 dark:text-white text-gray-700 sm:text-white text-center text-sm sm:text-base bg-[#C0EB3C] bg-opacity-70 hover:bg-opacity-90 duration-200 sm:font-semibold rounded-full px-24 py-1.5 cursor-pointer"
        phx-click="refresh_articles"
        >
        Nove vijesti
      </div>
    </div>
    """
  end

  def scroll_to_top(assigns) do
    ~H"""
    <div id="scroll-to-top-component" phx-update="ignore">
      <svg id="scroll-to-top"  width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg"
        class="invisible duration-300 ease-in-out opacity-0 fixed bottom-1 sm:bottom-5 right-5 z-50 cursor-pointer text-gray-600 dark:text-gray-400"
        phx-hook="ScrollToTopHook"
      >
        <path fill-rule="evenodd" clip-rule="evenodd" d="M14.0001 27.3332C21.3639 27.3332 27.3334 21.3636 27.3334 13.9998C27.3334 6.63604 21.3639 0.666504 14.0001 0.666504C6.63628 0.666504 0.666748 6.63604 0.666748 13.9998C0.666748 21.3636 6.63628 27.3332 14.0001 27.3332ZM14.7072 7.9594L20.0405 13.2927C20.431 13.6832 20.431 14.3164 20.0405 14.7069C19.65 15.0974 19.0168 15.0974 18.6263 14.7069L15 11.0806V19.3332C15 19.8855 14.5523 20.3332 14 20.3332C13.4477 20.3332 13 19.8855 13 19.3332V11.0808L9.37385 14.7069C8.98333 15.0974 8.35016 15.0974 7.95964 14.7069C7.56912 14.3164 7.56912 13.6832 7.95964 13.2927L13.2845 7.96785C13.3175 7.93406 13.3529 7.90259 13.3904 7.87372C13.4454 7.83134 13.5037 7.79546 13.5644 7.76609C13.6961 7.70228 13.8439 7.6665 14 7.6665C14.0008 7.6665 14.0016 7.6665 14.0023 7.66651C14.122 7.66678 14.2368 7.68808 14.3431 7.72691C14.476 7.77532 14.6006 7.85281 14.7072 7.9594Z" fill="#C0EB3C" fill-opacity="0.54"/>
      </svg>
    </div>
    """
  end

  defp short_relative_publish_time(relative_string) do
    relative_string
    |> String.replace([" sekundi"], "sec")
    |> String.replace([" minute", " minuta", " minutu", " minutes"], "m")
    |> String.replace([" sat", " sata", " sati", " hour"], "h")
  end
end
