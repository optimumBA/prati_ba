let ScrollHooks = {}

ScrollHooks.ScrollDownHook = {
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

ScrollHooks.InfiniteScrollHook = {
  mounted() {
    this.observer = new IntersectionObserver((entries) => {
      const entry = entries[0]
      if (entry.isIntersecting) {
        this.pushEvent('load_more')
      }
    })
    this.observer.observe(this.el)
  },
  beforeDestroy() {
    this.observer.unobserve(this.el)
  },
}

ScrollHooks.ScrollToTopHook = {
  mounted() {
    let scrollToTopButton = this.el

    window.addEventListener('scroll', () => {
      if (window.scrollY > 400) {
        scrollToTopButton.classList.replace('invisible', 'visible')
        scrollToTopButton.classList.replace('opacity-0', 'opacity-1')
      } else {
        scrollToTopButton.classList.replace('visible', 'invisible')
        scrollToTopButton.classList.replace('opacity-1', 'opacity-0')
      }
    })

    this.el.addEventListener('click', () => {
      window.scroll({
        top: 0,
        left: 0,
        behavior: 'smooth',
      })
    })
  },
}

export default ScrollHooks
