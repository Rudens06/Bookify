let Hooks = {}

Hooks.HideFlash =  {
  mounted() {
    setTimeout(() => {
      this.pushEvent("lv:clear-flash", { key: this.el.dataset.key })
      this.el.style.display = "none"
    }, 4000)
  }
}

export default Hooks