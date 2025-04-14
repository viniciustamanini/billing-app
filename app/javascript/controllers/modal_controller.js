import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Modal controller connected");
  }

  open(event) {
    event.preventDefault();
    console.log("Turbo frame loaded – opening modal");
    this.element.classList.remove("hidden");
  }

  close(event) {
    event.preventDefault();
    this.element.classList.add("hidden");
  }
}
