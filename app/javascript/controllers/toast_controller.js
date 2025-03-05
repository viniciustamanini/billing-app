import { Controller } from "@hotwired/stimulus";

console.log("loaded");

// Connects to data-controller="toast"
export default class extends Controller {
  static targets = ["closeButton"];

  connect() {
    console.log("connected");
    setTimeout(() => {
      this.element.classList.remove("hs-removing");
    }, 100);

    setTimeout(() => {
      this.hideToast();
    }, 3000);

    if (this.hasCloseButtonTarget) {
      this.closeButtonTarget.addEventListener("click", () => {
        console.log("exit clicked");
        this.hideToast();
      });
    }
  }

  hideToast() {
    console.log("clicked");
    this.element.classList.add("hs-removing");
    this.element.addEventListener(
      "transitioned",
      () => {
        this.element.remove();
      },
      { once: true },
    );
  }
}
