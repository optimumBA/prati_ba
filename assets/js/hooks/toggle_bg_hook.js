export default {
  mounted() {
    dark = false
    toggler = document.getElementById('background')
    bg = document.getElementById('page')
    logo = document.getElementById('logo')
    logo_dark = document.getElementById('logo_dark')
    sun = document.getElementById('sun')
    moon = document.getElementById('moon')
    nav_top = document.getElementById('navbar')
    nav_bottom = document.getElementById('nav_bottom')
    title = document.querySelectorAll('.title')
    link = document.querySelectorAll('.link')
    link_dark = document.querySelectorAll('.link_dark')
    container = document.querySelectorAll('.container')

    toggler.addEventListener('click', () => {
      dark = !dark
      if (dark == true) {
        changeToDark()
      } else {
        removeDark()
      }
    })

    const changeToDark = () => {
      bg.classList.add('bg-[#212936]')
      logo.classList.add('hidden')
      logo_dark.classList.remove('hidden')
      sun.classList.add('hidden')
      moon.classList.remove('hidden')
      nav_top.classList.remove('border-b-light_gray')
      nav_top.classList.add('border-b-[#363A44]')
      nav_bottom.classList.remove('border-b-light_gray')
      nav_bottom.classList.add('border-b-[#363A44]')

      for (let i = 0; i < title.length; i++) {
        title[i].classList.add('text-[#D2D5DA]')
      }

      for (let i = 0; i < link.length; i++) {
        link[i].classList.add('hidden')
      }
      for (let i = 0; i < link_dark.length; i++) {
        link_dark[i].classList.remove('hidden')
      }
      for (let i = 0; i < container.length; i++) {
        container[i].classList.remove('border-b-[#D9D9D9]')
        container[i].classList.add('border-b-[#363A44]')
      }
    }

    const removeDark = () => {
      bg.classList.remove('bg-[#212936]')
      logo.classList.remove('hidden')
      logo_dark.classList.add('hidden')
      sun.classList.remove('hidden')
      moon.classList.add('hidden')
      nav_top.classList.add('border-b-light_gray')
      nav_top.classList.remove('border-b-[#363A44]')
      nav_bottom.classList.add('border-b-light_gray')
      nav_bottom.classList.remove('border-b-[#363A44]')

      for (let i = 0; i < title.length; i++) {
        title[i].classList.remove('text-[#D2D5DA]')
      }
      for (let i = 0; i < link.length; i++) {
        link[i].classList.remove('hidden')
      }
      for (let i = 0; i < link_dark.length; i++) {
        link_dark[i].classList.add('hidden')
      }
      for (let i = 0; i < container.length; i++) {
        container[i].classList.add('border-b-[#D9D9D9]')
        container[i].classList.remove('border-b-[#363A44]')
      }
    }
  },
}
