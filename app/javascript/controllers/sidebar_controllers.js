// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay", "menuOpenIcon", "menuCloseIcon"]
  
  connect() {
    // Inicializa o estado se necessário
  }

  toggle() {
    this.panelTarget.classList.toggle('-translate-x-full')
    this.overlayTarget.classList.toggle('hidden')
    this.menuOpenIconTarget.classList.toggle('hidden')
    this.menuCloseIconTarget.classList.toggle('hidden')
  }

  hide() {
    this.panelTarget.classList.add('-translate-x-full')
    this.overlayTarget.classList.add('hidden')
    this.menuOpenIconTarget.classList.remove('hidden')
    this.menuCloseIconTarget.classList.add('hidden')
  }
}