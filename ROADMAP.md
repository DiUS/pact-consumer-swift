# ROADMAP to Native
- Switch to Native implementation by default.
- Improve documentation.
- Document on how to turn on debug output of mock server.
- Unit Tests around MockService and NativeMockServer
- Fix Swift Package Manager support
- Fix build of native library (cargo-lipo doesn't support rust workspaces)
- Investigate whether seperate tvOS project works without Rust Bitcode support. https://github.com/rust-lang/rust/issues/35968

Cleanup
- Chain promises properly...?
- Remove Nimble dependency

Matchers:
- ~~Type~~
- ~~Term~~
- ArrayLike

Future:
- Remove ruby implmentation
- JSON generation and use swift types properly
