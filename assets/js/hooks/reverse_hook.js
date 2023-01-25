export default {
  mounted() {
    var articles = document.querySelectorAll('.articles')
    for (let i = 0; i < articles.length; i++) {
      if (i % 2 === 0) {
        articles[i].classList.add('lg:flex-row-reverse')
      }
    }

    var text_reverse = document.querySelectorAll('.text')
    for (let i = 0; i < text_reverse.length; i++) {
      if (i % 2 === 0) {
        text_reverse[i].classList.remove('lg:pl-6')
      }
    }
  },
}
