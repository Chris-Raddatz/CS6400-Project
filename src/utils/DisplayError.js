class DisplayError extends Error {
  constructor(message, code) {
    super(message);
    this.name = "DisplayError";
    this.code = code;
  }
}

module.exports = DisplayError;
