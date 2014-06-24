#!/bin/sh

BASEDIR=$(dirname $0)

set -e

dart --checked $BASEDIR/sass_test.dart $*
dart --checked $BASEDIR/sass_file_test.dart $*
dart --checked $BASEDIR/transformer_test.dart $*
dart --checked $BASEDIR/inlined_sass_transformer_test.dart $*
dart --checked $BASEDIR/integration_test.dart $*
