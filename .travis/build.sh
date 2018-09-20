#!/usr/bin/env bash 

if [[ $TRAVIS_BRANCH == 'master' ]]
	fastlane test
else
	fastlane fir
fi