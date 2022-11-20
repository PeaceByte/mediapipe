#!/bin/sh

#Install Xcode, then install the Command Line Tools using:
xcode-select --install
#Install Bazelisk .
brew install bazelisk
#Set Python 3.7 as the default Python version and install the Python “six” library. This is needed for TensorFlow.
pip3 install --user six
pip3 install numpy
#build
bazel build -c opt --config=ios_arm64 mediapipe/objc:mediapipe_framework_ios
