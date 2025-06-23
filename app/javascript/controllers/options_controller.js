import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="options"
export default class extends Controller {
  static targets = ["select", "card", "dueDate"];

  connect() {}

  updateOffer(event) {
    const select = event.target;
    const segmentId = select.dataset.segmentId;
    const installments = select.value;
    const dueDate = this.dueDateTarget.value;
    const url = select.dataset.segmentUrl;

    this.fetchOfferUpdate(url, segmentId, installments, dueDate);
  }

  updateAllOffers() {
    const dueDate = this.dueDateTarget.value;

    this.selectTargets.forEach((select) => {
      const segmentId = select.dataset.segmentId;
      const installments = select.value;
      const url = select.dataset.segmentUrl;

      this.fetchOfferUpdate(url, segmentId, installments, dueDate);
    });
  }

  fetchOfferUpdate(url, segmentId, installments, dueDate) {
    fetch(`${url}?installments=${installments}&proposed_due_date=${dueDate}`, {
      headers: {
        Accept: "text/html",
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => response.text())
      .then((html) => {
        const cardElement = document.getElementById(
          `segment-${segmentId}-offer`,
        );
        if (cardElement) {
          cardElement.innerHTML = html;
        }
      })
      .catch((error) => {
        console.error("Error updating offer:", error);
      });
  }

  submitRenegotiation(event) {
    const button = event.currentTarget;
    const confirmMessage = button.dataset.confirm;

    if (confirmMessage && !confirm(confirmMessage)) {
      return;
    }

    const form = document.getElementById("renegotiation_form");

    form.querySelector('input[name="strategy"]').value =
      button.dataset.strategy;
    form.querySelector('input[name="installments"]').value =
      button.dataset.installments;
    form.querySelector('input[name="proposed_total_amount"]').value =
      button.dataset.proposedTotalAmount;
    form.querySelector('input[name="proposed_due_date"]').value =
      button.dataset.dueDate;
    form.querySelector('input[name="segment_id"]').value =
      button.dataset.segmentId;

    form.submit();
  }

  submitCustomerRenegotiation(event) {
    const button = event.currentTarget;
    const confirmMessage = button.dataset.confirm;

    if (confirmMessage && !confirm(confirmMessage)) {
      return;
    }

    const form = document.getElementById("renegotiation_form");

    form.querySelector('input[name="segment_id"]').value =
      button.dataset.segmentId;
    form.querySelector('input[name="installments"]').value =
      button.dataset.installments;
    form.querySelector('input[name="proposed_total_amount"]').value =
      button.dataset.proposedTotalAmount;
    form.querySelector('input[name="proposed_due_date"]').value =
      button.dataset.dueDate;

    form.submit();
  }
}
