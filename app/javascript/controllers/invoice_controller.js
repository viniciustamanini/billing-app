import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="invoice"
export default class extends Controller {
  static targets = ["items"];

  removeItem(event) {
    event.preventDefault();

    const item = event.target.closest("[data-invoice-target='item']");
    const destroyInput = item.querySelector("input[name*='_destroy']");

    if (destroyInput) {
      destroyInput.value = "1";
    }

    item.style.display = "none";
  }
}
