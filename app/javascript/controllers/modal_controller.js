import { Controller } from "@hotwired/stimulus";

console.log("loading modal controller");
export default class extends Controller {
  static targets = ["content"];

  open(event) {
    event.preventDefault();
    const url = event.currentTarget.dataset.modalUrl;
    if (url) {
      fetch(url)
        .then((response) => response.text())
        .then((html) => {
          this.contentTarget.innerHTML = html;
          this.element.classList.remove("hidden");
        })
        .catch((error) => {
          console.error("Error loading modal content:", error);
        });
    } else {
      this.element.classList.remove("hidden");
    }
  }

  close(event) {
    event.preventDefault();
    this.element.classList.add("hidden");
    this.contentTarget.innerHTML = "";
  }

  closeOutside(event) {
    if (event.target === this.backgroundTarget) {
      this.close(event);
    }
    this.contentTarget.innerHTML = "";
  }
}
