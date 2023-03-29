defmodule PratiBaWeb.Components.Icons do
  use Phoenix.Component

  def moon(assigns) do
    ~H"""
    <svg
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      class="w-5 h-5 sm:w-6 sm:h-6"
    >
      <path
        d="M20.9999 12.79C20.8426 14.4922 20.2038 16.1144 19.1581 17.4668C18.1125 18.8192 16.7034 19.8458 15.0956 20.4265C13.4878 21.0073 11.7479 21.1181 10.0794 20.7461C8.41092 20.3741 6.8829 19.5345 5.67413 18.3258C4.46536 17.117 3.62584 15.589 3.25381 13.9205C2.88178 12.252 2.99262 10.5121 3.57336 8.9043C4.15411 7.29651 5.18073 5.88737 6.53311 4.84175C7.8855 3.79614 9.5077 3.15731 11.2099 3C10.2133 4.34827 9.73375 6.00945 9.85843 7.68141C9.98312 9.35338 10.7038 10.9251 11.8893 12.1106C13.0748 13.2961 14.6465 14.0168 16.3185 14.1415C17.9905 14.2662 19.6516 13.7866 20.9999 12.79Z"
        stroke="currentColor"
        stroke-width="1.3"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  def sun(assigns) do
    ~H"""
    <svg
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      class="w-5 h-5 sm:w-6 sm:h-6"
    >
      <g clip-path="url(#clip0_169_221)">
        <path
          d="M12 17C14.7614 17 17 14.7614 17 12C17 9.23858 14.7614 7 12 7C9.23858 7 7 9.23858 7 12C7 14.7614 9.23858 17 12 17Z"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M12 1V3"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M12 21V23"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M4.21997 4.22L5.63997 5.64"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M18.3601 18.36L19.7801 19.78"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M1 12H3"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M21 12H23"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M4.21997 19.78L5.63997 18.36"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <path
          d="M18.3601 5.64L19.7801 4.22"
          stroke="currentColor"
          stroke-width="1.2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </g>
      <defs>
        <clipPath id="clip0_169_221">
          <rect width="24" height="24" fill="white" />
        </clipPath>
      </defs>
    </svg>
    """
  end

  def article_link(assigns) do
    ~H"""
    <svg
      width="16"
      height="17"
      viewBox="0 0 16 17"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      class="w-3 sm:w-4 mr-1 sm:mr-2"
    >
      <path
        d="M9.99996 5.16666H12C12.4377 5.16666 12.8712 5.25288 13.2756 5.42039C13.68 5.58791 14.0475 5.83344 14.357 6.14297C14.6665 6.4525 14.912 6.81996 15.0796 7.22438C15.2471 7.6288 15.3333 8.06225 15.3333 8.49999C15.3333 8.93773 15.2471 9.37118 15.0796 9.7756C14.912 10.18 14.6665 10.5475 14.357 10.857C14.0475 11.1665 13.68 11.4121 13.2756 11.5796C12.8712 11.7471 12.4377 11.8333 12 11.8333H9.99996M5.99996 11.8333H3.99996C3.56222 11.8333 3.12877 11.7471 2.72435 11.5796C2.31993 11.4121 1.95247 11.1665 1.64294 10.857C1.01782 10.2319 0.666626 9.38404 0.666626 8.49999C0.666626 7.61593 1.01782 6.76809 1.64294 6.14297C2.26806 5.51785 3.1159 5.16666 3.99996 5.16666H5.99996"
        stroke="#C0EB3C"
        stroke-width="1.2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path d="M5.33337 8.5H10.6667" stroke="#C0EB3C" stroke-linecap="round" stroke-linejoin="round" />
    </svg>
    """
  end
end
