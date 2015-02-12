import BrightFutures

@objc public class PactResult {
  public typealias CompleteCallback = (PactVerificationResult) -> ()
  let promise = Promise<String>()

  public func onComplete(complete: CompleteCallback) {
    self.promise.future.onSuccess { result in
      complete(PactVerificationResult.Passed)
    }
    self.promise.future.onFailure { error in
      complete(PactVerificationResult.Failed)
    }
  }

  func passed(message: String) {
    promise.success(message)
  }

  func failed(error: NSError) {
    promise.failure(error)
  }
}
