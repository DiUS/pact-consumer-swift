# ROADMAP to Native

- Cleanup MockServer repo and build
- ~~Response Body matchers~~
- ~~Request Body matchers~~
- ~~Query parameters as dictionaries~~
- Query parameter matchers
- ~~Path matchers~~
- ~~Header matchers~~
- Make output location of pact files configurable
- Figure out how to make location of pact files same as current Project directory.
- Add logging configuration to output pact sent to mock server.
- Document on how to turn on debug output of mock server.
- Unit Tests around MockService and NativeMockServer
- Fix Swift Package Manager support (breaks with NativeMockServer dependency -- local dependency not supported?)
- Fix build of native library (cargo-lipo doesn't support rust workspaces)
- Investigate whether seperate tvOS project works without Rust Bitcode support. https://github.com/rust-lang/rust/issues/35968

Matchers:
- ~~Type~~
- ~~Term~~
- ArrayLike
