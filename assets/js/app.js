// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
import './user_socket.js'

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from 'topbar'
import DisplayTimeHook from './hooks/display_time_hook'
import HeaderHook from './hooks/header_hook'
import InfiniteScrollHook from './hooks/infinite_scroll_hook'
import ScrollDownHook from './hooks/scroll_down_hook'
import ToggleBgHook from './hooks/toggle_bg_hook'

Hooks = {
  DisplayTimeHook,
  HeaderHook,
  InfiniteScrollHook,
  ScrollDownHook,
  ToggleBgHook
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', (info) => topbar.show())
window.addEventListener('phx:page-loading-stop', (info) => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

import userSocket from './user_socket'
import Analytics from './analytics'

if (userSocket) {
  let analytics = new Analytics(userSocket)
  analytics.track()
}

const isDarkMode = () =>
  window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches

if (
  (!('color-theme' in localStorage) && isDarkMode()) ||
  localStorage.getItem('color-theme') === 'dark'
) {
  document.documentElement.classList.add('dark')
} else {
  document.documentElement.classList.remove('dark')
}
