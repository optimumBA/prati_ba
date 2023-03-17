export default {
    mounted() {

        let header = this.el
        let appLogo = header.querySelector('#app-logo')
        let appLogoDark = header.querySelector('#app-logo-dark')

        const headerPos = header.getBoundingClientRect();

        document.addEventListener("scroll", (event) => {
            const currentScroll = window.pageYOffset;

            if (currentScroll > headerPos.bottom) {
                appLogo.classList.add('sm:w-24')
                appLogoDark.classList.add('sm:w-24')
            } else {
                appLogo.classList.remove('sm:w-24')
                appLogoDark.classList.remove('sm:w-24')
            }
        });
    },
}