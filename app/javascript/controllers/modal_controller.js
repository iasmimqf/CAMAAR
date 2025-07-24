// app/javascript/controllers/modal_controller.js

import { Controller } from "@hotwired/stimulus"

// Conecta-se ao data-controller="modal"
export default class extends Controller {
    // O 'element' é o próprio div do modal

    // Ação chamada por data-action="click->modal#open"
    open(event) {
        event.preventDefault()
        this.element.classList.remove("hidden")
    }

    // Ação chamada por data-action="click->modal#close"
    close(event) {
        event.preventDefault()
        this.element.classList.add("hidden")
    }
}