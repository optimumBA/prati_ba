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
    let scrollToTopButton = document.getElementById('scroll-to-top')

    this.observer = new IntersectionObserver((entries) => {
      const entry = entries[0]
      if (entry.isIntersecting) {
        this.pushEvent('load_more')
        setTimeout(() => {
          scrollToTopButton.classList.remove('hidden')
        }, 100)
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
        scrollToTopButton.classList.remove('hidden')
      } else {
        scrollToTopButton.classList.add('hidden')
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
