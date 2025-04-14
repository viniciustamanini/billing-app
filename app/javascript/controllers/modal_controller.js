import { Controller } from "@hotwired/stimulus";

console.log("loaded modal.js");
export default class extends Controller {
  connect() {
    console.log("Modal controller connected");
  }

  open(event) {
    console.log("Modal frame loaded, opening modal");
    event.preventDefault();
    this.element.classList.remove("hidden");
  }

  close(event) {
    event.preventDefault();
    this.element.classList.add("hidden");
  }
}
