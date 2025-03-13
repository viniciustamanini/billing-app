import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["closeButton", "counter"];

  connect() {
    // Total duration in milliseconds before auto-close
    this.totalTime = 3000;
    this.remainingTime = this.totalTime;

    // Setup the counter element as a progress bar
    this.counterTarget.style.width = "100%";
    this.counterTarget.style.height = "4px"; // adjust height as needed
    this.counterTarget.style.backgroundColor = "#3B82F6"; // Tailwind blue-500
    this.counterTarget.style.display = "block";

    // Start the countdown timer and progress update
    this.startCountdown();

    // Pause countdown on mouse enter and resume on mouse leave
    this.element.addEventListener("mouseenter", () => this.pauseCountdown());
    this.element.addEventListener("mouseleave", () => this.resumeCountdown());

    // Listen for manual close button click
    if (this.hasCloseButtonTarget) {
      this.closeButtonTarget.addEventListener("click", () => {
        this.closeToast();
      });
    }
  }

  startCountdown() {
    const updateInterval = 50;

    // Set auto-close timeout using the current remaining time
    this.autoCloseTimeout = setTimeout(() => {
      this.closeToast();
    }, this.remainingTime);

    // Update the progress bar at regular intervals
    this.progressInterval = setInterval(() => {
      this.remainingTime -= updateInterval;
      let percentage = (this.remainingTime / this.totalTime) * 100;
      if (percentage < 0) percentage = 0;
      this.counterTarget.style.width = percentage + "%";

      // If countdown reaches zero, stop the interval
      if (this.remainingTime <= 0) {
        clearInterval(this.progressInterval);
      }
    }, updateInterval);
  }

  pauseCountdown() {
    clearTimeout(this.autoCloseTimeout);
    clearInterval(this.progressInterval);
  }

  resumeCountdown() {
    // Resume the countdown with the remaining time
    this.startCountdown();
  }

  closeToast() {
    clearTimeout(this.autoCloseTimeout);
    clearInterval(this.progressInterval);
    this.element.remove();
  }
}
