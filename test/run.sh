#!/bin/sh

BASEDIR=$(dirname $0)

set -e

dart $BASEDIR/sass_test.dart
dart $BASEDIR/transformer_test.dart
