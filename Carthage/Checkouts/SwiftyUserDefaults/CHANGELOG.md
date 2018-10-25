### Next

### 4.0.0-alpha.1 (2018-05-08)

* Added generic subscripts support (better `DefaultsKey` init diagnostics and accessing `Defaults[.key]`) [@sunshinejr](https://github.com/sunshinejr)
* Added default values protocols (`DefaultsDefaultValueType`, `DefaultsDefaultArrayValueType`) - this means that you can extend any type with default value so you can create non-optional `DefaultsKey` afterwards! [@sunshinejr](https://github.com/sunshinejr)
* Added default values in `DefaultsKey`, e.g. `DefaultsKey<String>("test", defaultValue: "default value")` [@sunshinejr](https://github.com/sunshinejr)
* Added better support for custom types: using `DefaultsSerializable`, when your type implements `NSCoding`, `RawRepresentable` (enums as well) or `Codable`, you get default implementations for free! [@sunshinejr](https://github.com/sunshinejr)
* Added automatic array support for any type that is available to `SwiftyUserDefaults` (means custom with `DefaultsSerializable` as well!) [@sunshinejr](https://github.com/sunshinejr)
* Added Swift Package Manager support! [@sunshinejr](https://github.com/sunshinejr)
* Added `[URL]` built-in support! [@sunshinejr](https://github.com/sunshinejr)
* A lot of infrastructure changes (CI, project), around 350 tests to make sure all of the changes work properly! [@sunshinejr](https://github.com/sunshinejr)
* Removed legacy strings based API (`Defaults["test"]`), `Dictionary` and `Any` support (sorry, with all the changes in the library we had to, but you _probably_ can bring it back with `DefaultsSerializable` anyways 😅) [@sunshinejr](https://github.com/sunshinejr)

### 3.0.1 (2016-11-12)

* Fix for Swift Package Manager #114 @max-potapov

### 3.0.0 (2016-09-14)

This is the Swift 3 update version.

It contains no major changes in the library itself, however it does change some APIs because of Swift 3 requirements.

* Update documentation and README for Swift 3
* Updated for Swift 3 and Xcode 8 compatibility #91 @askari01
* Updated for Swift 3 beta 4 #102 @rinatkhanov
* Updated for Swift 3 beta 6 #106 @ldiqual

---

### 2.2.1 (2016-08-03)

* `NSUserDefaults.set()` is now public (useful for adding support for custom types) #85 @goktugyil
* Support for Xcode 8 (Swift 2.3) for Carthage users #100 @KevinVitale

### 2.2.0 (2016-04-10)

* Support for `archive()` and `unarchive()` on `RawRepresentable` types
* Improved documentation

### 2.1.3 (2016-03-02)

* Fix Carthage build
* Suppress deprecation warnings in tests

### 2.1.2 (2016-03-01)

* Fixed infinite loop bug
* Added Travis CI integration
* Added Swift Package Manager support

### 2.1.1 (2016-02-29)

* Documentation improvements

### 2.1.0 (2016-02-29)

* Added `removeAll()`
* Added tvOS and watchOS support
* Fixed error when linking SwiftyUserDefaults with app extension targets
* Minor tweaks and fixes

### 2.0.0 (2015-09-18)

* Introducing statically-typed keys
  * Define keys using `DefaultsKey`
  * Extend magic `DefaultsKeys` class to get access to `Defaults[.foo]` shortcut
  * Support for all basic types, both in optional and non-optional forms
  * Support for arrays of basic types, such as `[Double]` or `[String]?`
  * Support for basic `[String: AnyObject]` dictionaries
  * `hasKey()` and `remove()` for static keys
  * You can define support for static keys of custom `NSCoder`-compliant types
  * Support for `NSURL` in statically-typed keys
* [Carthage] Added OS X support

**Deprecations**

* `+=`, `++`, `?=` operators are now deprecated in favor of statically-typed keys

---

### 1.3.0 (2015-06-29)

* Added non-optional `Proxy` getters
  * string -> stringValue, etc.
  * non-optional support for all except NSObject and NSDate getters
* Fixed Carthage (Set iOS Deployment target to 8.0)
* Converted tests to XCTest

### 1.2.0 (2015-06-15)

* Carthage support

### 1.1.0 (2015-04-13)

* Swift 1.2 compatibility
* Fixed podspec

### 1.0.0 (2015-01-26)

* Initial release
* `Proxy` getters:
  * String, Int, Double, Bool
  * NSArray, NSDictionary
  * NSDate, NSData
  * NSNumber, NSObject
* subscript setter
* `hasKey()`
* `remove()`
* `?=`, `+=`, `++` operators on `Proxy`
* global `Defaults` shortcut
