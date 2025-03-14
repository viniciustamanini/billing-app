// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "background"];

  open(event) {
    event.preventDefault();
    this.element.classList.remove("hidden");
  }

  close(event) {
    event.preventDefault();
    this.element.classList.add("hidden");
  }

  // Fecha o modal ao clicar fora do conteúdo
  closeOutside(event) {
    if (event.target === this.backgroundTarget) {
      this.close(event);
    }
  }
}
