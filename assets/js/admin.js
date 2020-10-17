import "../css/admin.scss"

import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import Analytics from "./admin/analytics"

let analytics = new Analytics();

let Hooks = {}
Hooks.Analytics = {
  mounted() {
    analytics.drawMainGraph();
  },
  updated() {
    analytics.drawMainGraph();
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

liveSocket.connect()
