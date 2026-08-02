import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "fallback"]

  showFallback() {
    this.imageTarget.classList.add("hidden")
    this.fallbackTarget.classList.remove("hidden")
  }
}
