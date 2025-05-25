import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    document.addEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this));
    document.addEventListener('keydown', this.handleKeyDown.bind(this));
    this.element.addEventListener('click', this.handleBackdropClick.bind(this));
  }

  disconnect() {
    document.removeEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this));
    document.removeEventListener('keydown', this.handleKeyDown.bind(this));
    this.element.removeEventListener('click', this.handleBackdropClick.bind(this));
  }

  open(event) {
    event.preventDefault();
    this.element.classList.remove("hidden");
  }

  close(event) {
    if (event) event.preventDefault();
    this.element.classList.add("hidden");
    this.clearModalContent();
  }

  handleBackdropClick(event) {
    if (event.target === this.element) {
      this.close();
    }
  }

  handleContentClick(event) {
    // Prevent click from bubbling up to backdrop
    event.stopPropagation();
  }

  handleSubmitEnd(event) {
    const fetchResponse = event.detail.fetchResponse;
    
    if (fetchResponse.succeeded) {
      if (!fetchResponse.response.headers.get("Content-Type")?.includes("turbo-stream")) {
        this.close();
      }
    }
  }

  handleKeyDown(event) {
    if (event.key === 'Escape') {
      this.close();
    }
  }

  clearModalContent() {
    const frame = this.element.querySelector('#modal-frame');
    if (frame) {
      frame.innerHTML = '';
    }
  }
}
