public enum PactError: Error {
  case setupError(String)
  case executionError(String)
  case missmatches(String)
}
