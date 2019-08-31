-en # 0.6.1 - Bugfix Release


* 57ccbd6 - fix(objc): add escaping modifier to allow for testComplete function to be called… (#71) (Matt Arturi, Sat Jul 27 09:43:09 2019 -0400)
* a611dce - chore: Only run coverage report when tests pass (Andrew Spinks, Sat Jul 27 20:48:05 2019 +0900)
* cacde03 - chore: Fix test failures not failing travis build. (Andrew Spinks, Sat Jul 27 20:47:52 2019 +0900)
* cc66ee5 - test: Add test around pact mock service to make refactors easier. (Andrew Spinks, Wed Jul 3 19:29:27 2019 +0900)
* 31fdfc7 - fix: Revert "Refactor pact mock server network calling code and upgrade to swift 5 (#53)" which introduced a bug where messages from the mock server were no longer being returned. (Andrew Spinks, Thu Jul 18 17:35:45 2019 +0900)
* 8a42f89 - fix(lint): Parameter alignment (Marko Justinek, Tue Jul 2 06:29:45 2019 +1000)
* 217b5e2 - chore(lint): moved linting into a portable script (#66) (Marko Justinek, Mon Jul 1 21:00:51 2019 +1000)
* aa25c8f - Cleanup access controls on classes to hide internal concepts. (Andrew Spinks, Sat Jun 29 16:50:33 2019 +0900)
* 1665942 - Remove unused .ruby-version file (#65) (Marko Justinek, Fri Jun 28 17:32:07 2019 +1000)
* feaa5d5 - Removes watchOS target and scheme (#64) (Marko Justinek, Fri Jun 28 17:30:39 2019 +1000)


# 0.6.0 - Maintenance Release

* 9605227 - Cleanup build settings so ci build can be more easily reproduced locally. (#59) (andrewspinks, Tue Jun 25 17:32:54 2019 +0900)
* cdecfbc - Fixes bitcode related issue when used from CocoaPods. (Kyle Hammond, Mon Jun 24 10:36:16 2019 -0500)
* 848f4c5 - Remove quick dependency from requirements. It is only used for internal tests. (#58) (andrewspinks, Sun Jun 23 11:19:26 2019 +0900)
* 8688fdc - Refactor pact mock server network calling code and upgrade to swift 5 (#53) (Marko Justinek, Wed Jun 19 17:32:45 2019 +1000)
* 23296ce - Completely removed Alamofire in favor of simple networking calls. (#51) (Kyle Hammond, Wed Jun 12 18:53:11 2019 -0500)
* 3ed97f1 - Update dependencies (Mihai Georgescu, Mon Mar 25 23:12:14 2019 +0000)
* 28e1588 - Fix cocoa pods release version number and release script. (Andrew Spinks, Thu Jan 24 20:17:51 2019 +0900)

# 0.5.3 - Bugfix Release

* a1cd000 - Update cocoapods dependencies. (Andrew Spinks, Thu Jan 24 19:34:14 2019 +0900)
* 5ebc062 - Update pact-mock-service versions (Andrew Spinks, Thu Jan 24 17:29:40 2019 +0900)
* 2e77868 - Update Cartfile.resolved for use with bootstrap on CI (Marko Justinek, Thu Jan 24 09:06:45 2019 +1100)
* f8899f8 - Update Quick dependency to use “master” (Marko Justinek, Thu Jan 24 08:38:31 2019 +1100)
* 596b6b8 - Update travis CI env matrix (Marko Justinek, Thu Jan 24 08:26:12 2019 +1100)
* 8c4d3cf - Bumps up versions of all dependencies (Marko Justinek, Wed Jan 23 23:58:20 2019 +1100)
* 4198e38 - Bump up Alamofire version (Marko Justinek, Wed Jan 23 23:47:04 2019 +1100)
* 5897e28 - Updates travis pipeline to run tests on iOS 12.1 and 11.3 (Marko Justinek, Wed Jan 23 23:30:14 2019 +1100)
* 0e7212b - Project updates for Swift 4.2 (Marko Justinek, Wed Jan 23 23:21:23 2019 +1100)
* 6ca5c37 - Update BrightFutures dependency version (Marko Justinek, Wed Jan 23 23:12:39 2019 +1100)
* d639fe7 - Update readme (Marko Justinek, Wed Jan 23 23:12:23 2019 +1100)
* e1c4596 - Removed reference to non-standalone pact mock service (Marko Justinek, Fri May 18 11:00:12 2018 +1000)
* 2a667c2 - Updates README to encourage usage of pact-ruby-standalone (Marko Justinek, Thu May 17 08:27:07 2018 +1000)
* 5ec6eb3 - bump cocoapods version to 0.5.2 (Andrew Spinks, Tue May 8 17:22:01 2018 +0900)

# 0.5.2 - Bugfix Release

* 52cf980 - Update release script to work better with cocoa pods (Andrew Spinks, Tue May 8 17:09:25 2018 +0900)
* 2bc59b5 - Update gems (Andrew Spinks, Tue May 8 16:26:54 2018 +0900)
* 6749fdc - Merge pull request #38 from stitchfix/master (andrewspinks, Tue May 1 11:46:08 2018 +0900)
* 26cab90 - Update BrightFutures (Robbin Voortman, Wed Apr 25 08:51:25 2018 +0200)
* b538409 - wait on verify to complete before allowing tests to continue to prevent race condition (Eric Vennaro, Tue Apr 24 15:31:03 2018 -0700)
* 3e1edc3 - move to brew update (Stephen, Thu Jan 4 16:42:57 2018 -0800)
* db7abe5 - move to brew bundle (Stephen, Thu Jan 4 15:37:59 2018 -0800)
* 8bc8fc0 - Create Brewfile (Stephen, Thu Jan 4 15:37:26 2018 -0800)
* 9c5678b - Update cocopods version number (Andrew Spinks, Thu Oct 26 19:19:37 2017 +0900)

# 0.5.1 - Bugfix Release

* 1b6ba70 - Fixed issue preventing the pact writing (Angel G. Olloqui, Wed Oct 25 12:30:38 2017 +0200)
* 44146ba - Updates documentation (Marko Justinek, Wed Oct 4 10:41:17 2017 +1100)
* a5d24a0 - Build script improvements (Marko Justinek, Wed Oct 4 10:29:54 2017 +1100)
* ff6939f - Fixes links (Marko Justinek, Wed Oct 4 10:09:08 2017 +1100)
* 0aa3bd6 - Fixes links (Marko Justinek, Wed Oct 4 10:09:08 2017 +1100)
* 10ddac3 - Updates README (Marko Justinek, Wed Oct 4 08:35:12 2017 +1100)
* c9806df - Updates README (Marko Justinek, Wed Oct 4 08:16:21 2017 +1100)
* 44b087f - Release script runs pod spec lint before versioning and tagging (Marko Justinek, Wed Oct 4 08:07:39 2017 +1100)
* d8c22b0 - Updates readme and contributing. (Marko Justinek, Wed Oct 4 08:07:03 2017 +1100)

# 0.5.0 - macOS and SwiftPM support

* 51b567a - Adds support for macOS and tvOS targets using Carthage and SwiftPM (#32) (Marko, Mon Oct 2 12:46:52 2017 +1100)
* 5248ba4 - Fix swiftlint upgrade. (#30) (andrewspinks, Sat Sep 23 15:03:52 2017 +0900)
* c74eaae - Swift 4 compatible framework (#27) (Marko Justinek, Sat Sep 23 15:14:42 2017 +1000)
* 2dd464d - Allow matchers to be used with headers, and add specs around query parameter matchers. (Andrew Spinks, Thu Jun 1 14:21:06 2017 +0900)
* 2d7eb6f - Fix travisci badge. (Andrew Spinks, Thu Jun 1 07:54:11 2017 +0900)
* 414159d - Fix cocoapods publish. (Andrew Spinks, Wed May 31 15:30:19 2017 +0900)
* 878b70b - bump version to 0.4.3 (Andrew Spinks, Wed May 31 15:29:41 2017 +0900)

# 0.4.2 - Bugfix Release

* 891920f - bump version to 0.4.2 (Andrew Spinks, Wed May 31 14:55:31 2017 +0900)
* 45edc9f - Add release script to make a consistent process. (Andrew Spinks, Wed May 31 14:52:31 2017 +0900)
* 9e440a3 - Improve output of errors when a mismatch occurs. (Andrew Spinks, Wed May 31 12:19:02 2017 +0900)
* ce528bc - Update dependencies. (Andrew Spinks, Wed May 31 11:45:15 2017 +0900)
* b29de5f - Remove unused workspace (Andrew Spinks, Wed May 31 11:45:03 2017 +0900)
* 23d3bf4 - Fix fastlane build command. (Andrew Spinks, Tue May 30 15:49:16 2017 +0900)
* c93c410 - Update mock server version (Andrew Spinks, Tue May 30 15:48:55 2017 +0900)
* e6e6e19 - Ignore swap files (Andrew Spinks, Tue May 30 14:54:30 2017 +0900)
* fbe2b46 - Fixes codecov.yml blank line (Marko Justinek, Tue May 30 10:08:24 2017 +1000)
* f99d8b5 - Adds codecov badge (Marko Justinek, Tue May 30 10:01:45 2017 +1000)
* 7fc985a - Updates build steps (Marko Justinek, Tue May 30 09:45:27 2017 +1000)
* 1dc353a - Changes codecov in travisci steps (Marko Justinek, Tue May 30 09:28:25 2017 +1000)
* cfba6cd - Adds codecov.yml settings file (Marko Justinek, Tue May 30 08:41:43 2017 +1000)
* f3de735 - Sends coverage data to codecov.io (Marko Justinek, Tue May 30 08:23:15 2017 +1000)
* 1852edf - Enables code coverage in scheme (Marko Justinek, Tue May 30 08:17:27 2017 +1000)
* 6425cb8 - Runs brew upgrade swiftlint (Marko Justinek, Mon May 29 12:48:17 2017 +1000)
* 90f72b9 - Forces brew update on TravisCI (Marko Justinek, Mon May 29 12:43:03 2017 +1000)
* 9d2cfe0 - Cleans up swiftlint.yml (Marko Justinek, Mon May 29 12:38:38 2017 +1000)
* a3dbadb - Removes script that installs SwiftLint (Marko Justinek, Mon May 29 12:30:51 2017 +1000)
* 0d66d39 - Cleans up code after default SwiftLint install (Marko Justinek, Mon May 29 12:27:53 2017 +1000)
* acf722f - Installs swiftlint using brew (Marko Justinek, Mon May 29 12:20:37 2017 +1000)
* 47914c6 - Reverts minValue to min to avoid breaking existing (Marko Justinek, Mon May 29 12:16:42 2017 +1000)
* d066976 - Reverts failing swiftlint test (Marko Justinek, Mon May 29 11:12:09 2017 +1000)
* bae0cf3 - Updates swiftlint with opt_in rules and tests failing scenario (Marko Justinek, Mon May 29 10:50:40 2017 +1000)
* 1726a06 - testing swiftlint throws error (Marko Justinek, Mon May 29 10:34:42 2017 +1000)
* fd4949b - testing swiftlint on travisCI (Marko Justinek, Mon May 29 10:00:17 2017 +1000)
* d3ac542 - Fixes deprecated sendSynchronousRequest:returningResponse:error method (Marko Justinek, Mon May 29 09:29:47 2017 +1000)
* 2277452 - Changes script order (Marko Justinek, Mon May 29 09:09:19 2017 +1000)
* 2e3ce09 - Changes TravisCI build order (Marko Justinek, Sat May 27 06:32:35 2017 +1000)
* bfc7e71 - Updates TravisCI build script to include SwiftLint (Marko Justinek, Fri May 26 20:21:20 2017 +1000)
* 0820504 - Updates Gemfile.lock (Marko, Fri May 26 13:39:43 2017 +1000)
* 6153b38 - Merge branch 'master' into swiftlint (Marko, Fri May 26 13:34:04 2017 +1000)
* e08bf36 - Update ruby dependencies which was referencing a library which seems to have been removed. Also update scan to version 1.0. (Andrew Spinks, Fri May 26 12:27:01 2017 +0900)
* a09cdd3 - Fixes build issues due changed method parameters (Marko, Fri May 26 12:22:14 2017 +1000)
* 8109eab - Removes spaces after "[" and before "]" (Marko, Fri May 26 12:20:42 2017 +1000)
* 9318dd0 - Introduces swiftlint (Marko, Thu May 25 18:53:35 2017 +1000)
* 34c5dac - Update dependencies (Andrew Spinks, Fri Dec 16 16:06:26 2016 +0900)
* 2d9a23d - Default timeout to 30 seconds. Add documentation. (Christi Viets, Thu Dec 15 07:57:41 2016 -0500)


