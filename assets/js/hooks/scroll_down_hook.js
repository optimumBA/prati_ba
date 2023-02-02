export default {
  mounted() {
    const scroll_down = () => {
      window.scrollBy({
        top: window.innerHeight,
        left: 0,
        behavior: 'smooth',
      })
    }
    const button = document.getElementById('scroll')
    button.addEventListener('click', scroll_down)
  },
}
