#!/usr/bin/env bash 

if [[ $TRAVIS_BRANCH == 'master' ]];then
	fastlane publish
elif [[ $TRAVIS_BRANCH == 'testflight' ]];then
	fastlane test
else
	fastlane fir
fi
