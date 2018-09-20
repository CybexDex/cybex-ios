#!/usr/bin/env bash 

if [[ $TRAVIS_BRANCH == 'master' ]];then
	fastlane test
else
	fastlane fir
fi
