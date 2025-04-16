import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["defaultCheckbox"];

  async toggleDefault(event) {
    event.preventDefault();
    const checkbox = event.currentTarget;
    const profileId = checkbox.dataset.profileId;
    const url = checkbox.dataset.url;

    if (!profileId || !url) return;

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Accept: "text/vnd.turbo-stream.html, application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        credentials: "same-origin",
      });

      if (!response.ok) {
        throw new Error("Failed to update default profile");
      }

      const contentType = response.headers.get("Content-Type");
      
      if (contentType && contentType.includes("text/vnd.turbo-stream.html")) {
        // Process Turbo Stream response
        const html = await response.text();
        Turbo.renderStreamMessage(html);
      } else {
        // Fallback for JSON response
        const result = await response.json();
        if (!result.success) {
          checkbox.checked = !checkbox.checked;
        }
      }
    } catch (error) {
      console.error("Error:", error);
      checkbox.checked = !checkbox.checked; // Revert the checkbox state
    }
  }
}
