import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sidebar", "navbar", "content", "toggle"];

  connect() {
    const sidebarState = localStorage.getItem("sidebarState") || "expanded";

    this.toggleSidebar(sidebarState === "collapsed");

    this.toggleTarget.addEventListener("click", () => {
      this.toggleSidebar();
    });
  }

  toggleSidebar(forceCollapse) {
    const isCurrentlyExpanded =
      this.sidebarTarget.classList.contains("expanded");
    const shouldCollapse =
      forceCollapse !== undefined ? forceCollapse : isCurrentlyExpanded;

    if (shouldCollapse) {
      this.sidebarTarget.classList.remove("expanded");
      this.sidebarTarget.classList.add("collapsed");

      this.navbarTarget.classList.remove("sidebar-expanded");
      this.navbarTarget.classList.add("sidebar-collapsed");

      this.contentTarget.classList.remove("sidebar-expanded");
      this.contentTarget.classList.add("sidebar-collapsed");

      this.toggleTarget.classList.remove("expanded");
      this.toggleTarget.classList.add("collapsed");

      // Update icon and text for collapsed state
      const iconElement = this.toggleTarget.querySelector(".material-icons");
      if (iconElement) {
        iconElement.textContent = "arrow_menu_open";
      }

      localStorage.setItem("sidebarState", "collapsed");
    } else {
      this.sidebarTarget.classList.remove("collapsed");
      this.sidebarTarget.classList.add("expanded");

      this.navbarTarget.classList.remove("sidebar-collapsed");
      this.navbarTarget.classList.add("sidebar-expanded");

      this.contentTarget.classList.remove("sidebar-collapsed");
      this.contentTarget.classList.add("sidebar-expanded");

      this.toggleTarget.classList.remove("collapsed");
      this.toggleTarget.classList.add("expanded");

      const iconElement = this.toggleTarget.querySelector(".material-icons");
      if (iconElement) {
        iconElement.textContent = "arrow_menu_close";
      }

      localStorage.setItem("sidebarState", "expanded");
    }
  }
}

