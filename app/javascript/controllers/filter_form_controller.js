import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 400 } }

  disconnect() {
    this.cancelPending()
  }

  search(event) {
    if (event.isComposing) return

    this.cancelPending()
    this.timeout = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  submit() {
    this.cancelPending()
    this.element.requestSubmit()
  }

  cancelPending() {
    clearTimeout(this.timeout)
  }
}
