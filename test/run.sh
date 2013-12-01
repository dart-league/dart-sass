#!/bin/sh

BASEDIR=$(dirname $0)

set -e

dart --checked $BASEDIR/sass_test.dart
dart --checked $BASEDIR/transformer_test.dart
