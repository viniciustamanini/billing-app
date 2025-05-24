import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="options"
export default class extends Controller {
  static targets = ["select", "card"];

  update(event) {
    const option = event.target.selectedOptions[0];

    const strategy = option.dataset.strategy;
    const installments = option.dataset.installments;
    const html = option.dataset.offerHtml;

    // Atualiza campos ocultos
    document.querySelector("input[name='strategy']").value = strategy;
    document.querySelector("input[name='installments']").value = installments;

    // Atualiza card
    const segmentId = event.target.dataset.segmentId;
    const card = document.querySelector(`#segment-${segmentId}-offer`);
    if (card) card.innerHTML = html;
  }
}
