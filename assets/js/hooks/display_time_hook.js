export default {
    mounted() {
        let currentTimeElement = this.el.querySelector('#current_time')

        currentTimeElement.innerHTML = getCurrentTime()

        setInterval(() => {
            currentTimeElement.innerHTML = getCurrentTime()
        }, 1000)

        function getCurrentTime() {
            let date = new Date()
            let current_time = date.toTimeString().slice(0, 5)
            return current_time
        }
    },
}