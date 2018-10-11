# cybex-ios

[![Build Status](https://travis-ci.org/CybexDex/cybex-ios.svg?branch=develop)](https://travis-ci.org/CybexDex/cybex-ios)

## Pre Build

- brew install lvillani/tap/carthage-copy-frameworks
- brew install wget 
- wget http://gufeng.life:8001/f/7a26d02d13e14302b053/?dl=1  -O tmp.zip && unzip -o tmp.zip && rm tmp.zip
- carthage bootstrap --no-use-binaries --platform iOS
- pod install
