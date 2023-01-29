defmodule PratiBaWeb.Components.ArticleComponent do
  use PratiBaWeb, :component

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage

  def article(assigns) do
    ~H"""
    <article phx-hook="ReverseHook" class="lg:px-10 lg:mt-6 lg:w-[907px] lg:h-[219px] sm:mt-7 sm:ml-2 sm:h-[120px] border-b-[1px] border-b-[#D9D9D9] border-w-[833px] " id={"article-" <> @article.id}>
      <%= link to: Routes.article_path(@socket, :show, @article), class: "articles relative flex",  target: "_blank", rel: "noopener" do %>
        <.article_image article={@article} />
        <.article_details article={@article} socket={@socket}/>
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
    <div class="text w-2/3 text-left lg:pl-6 sm:relative flex flex-col justify-between">
      <div class="lg:text-3xl sm:text-sm font-bold sm:overflow-hidden sm:pl-2 lg:h-[145px]"><h1><%= @article.title %></h1></div>



      <div class="details lg:pt-2 lg:pb-4 text-light_gray lg:text-base sm:text-xs sm:pl-2 flex items-center">
        <span class="flex items-center">
        <img src={Routes.static_path(@socket,"/images/link-2.png")} class="lg:pr-2 sm:pr-1"/>
        <span class="article-source border-b-[1px] border-b-light_gray "><%= @article.source.name %></span>
        </span>

        <span class="flex items-center">
         <img src={Routes.static_path(@socket,"/images/calendar.png")} class="lg:pr-2 lg:pl-2 sm:pr-1 sm:pl-1"/>
        <.publish_date article={@article} />
        </span>

        <span class="flex items-center">
        <img src={Routes.static_path(@socket,"/images/clock.png")} class="lg:pr-2 lg:pl-2 sm:pr-1 sm:pl-1"/>
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
     <div ckass="w-full">
       <div class="w-full flex relative items-center justify-center border-b-2 border-b-light_gray">
        <nav role="navigation" class="w-full">
        <section class="w-full flex items-center justify-around">
          <div class="cursor-pointer">
            <img src={Routes.static_path(@socket,"/images/sun.png")}>
          </div>

          <%= link to: Routes.article_index_path(@socket, :index) do %>
            <div>
              <img class="lg:py-4 sm:py-2" src={Routes.static_path(@socket, "/images/logo.png")} />
            </div>
            <% end %>

              <div class="cursor-pointer">
                <img class="cursor-pointer" src={Routes.static_path(@socket,"/images/search.png")}>
              </div>
        </section>
        </nav>
       </div>
       <div class="w-full flex items-center justify-center border-b-2 text-light_gray border-b-light_gray">
        <.date />
        <.sm_screen_date/>
        <.time socket={@socket}/>
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
     <div class="lg:flex items-center pl-2 sm:hidden">
        <img class="pr-2" src={Routes.static_path(@socket, "/images/clock.png")}/>
        <h1>
          <%= time %>
        </h1>
      </div>
    """
  end
end
