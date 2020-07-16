export default class Analytics {
  constructor(socket) {
    this.socket = socket;
  }

  track() {
    let channel = this.socket.channel("analytics", {})
    channel.join()
  }
}
