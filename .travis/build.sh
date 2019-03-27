#!/usr/bin/env bash 

security create-keychain -p $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain
security default-keychain -s ios-build.keychain
security unlock-keychain -p $CUSTOM_KEYCHAIN_PASSWORD ios-build.keychain
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

security import ../.travis/AppleWWDRCA.cer -k ios-build.keychain -A
security import ../.travis/nbl-dis.p12 -k ios-build.keychain -P $KEY_PASSWORD -A
security set-key-partition-list -S apple-tool:,apple: -s -k $KEY_PASSWORD ios-build.keychain > /dev/null

if [[ $TRAVIS_BRANCH == 'master' ]];then
	fastlane publish
elif [[ $TRAVIS_BRANCH == 'testflight' ]];then
	fastlane test
else
	fastlane fir
fi
