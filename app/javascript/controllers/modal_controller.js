// app/javascript/controllers/modal_controller.js

import { Controller } from "@hotwired/stimulus"

// Conecta-se ao data-controller="modal"
export default class extends Controller {
    static targets = ["modal"]
    
    // Ação chamada por data-action="click->modal#open"
    open(event) {
        event.preventDefault()
        console.log("Modal open called")
        const modal = document.getElementById("import-modal")
        if (modal) {
            console.log("Modal found, removing hidden class")
            modal.classList.remove("hidden")
            modal.style.display = "block"
            modal.style.visibility = "visible"
        } else {
            console.log("Modal not found!")
        }
    }

    // Ação chamada por data-action="click->modal#close"
    close(event) {
        event.preventDefault()
        const modal = document.getElementById("import-modal")
        if (modal) {
            modal.classList.add("hidden")
            modal.style.display = "none"
        }
    }
}