export default class Analytics {
  constructor(socket) {
    this.socket = socket
    this.channel = this.socket.channel('analytics', {})
  }

  track() {
    this.channel.join()

    let details = {
      siteLanguage: (navigator.language || navigator.userLanguage).substr(0, 2),
      screenWidth: screen.width,
      screenHeight: screen.height,
      screenColorDepth: screen.colorDepth,
      browserWidth: document.documentElement.clientWidth || window.outerWidth,
      browserHeight:
        document.documentElement.clientHeight || window.outerHeight,
    }

    this.channel.push('details', details)

    setInterval(() => {
      this.channel.push('ping', null)
    }, 60000)
  }
}
