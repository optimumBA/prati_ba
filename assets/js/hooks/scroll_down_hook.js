export default {
  mounted() {
    const scrollDown = () => {
      window.scrollTo({
        top: document.body.scrollHeight,
        behavior: 'smooth',
      })
    }
    const button = document.getElementById('scroll')
    button.addEventListener('click', scrollDown)
  },
}
