#!/usr/bin/env bats

@test "usercheck exits non-zero when not run as user pi" {
  source "$BATS_TEST_DIRNAME/../assets/func.sh"
  USER="tester"
  run usercheck
  [ "$status" -ne 0 ]
}

@test "MacOS_version 7 sets variables" {
  source "$BATS_TEST_DIRNAME/../assets/func.sh"
  Base_dir() { :; }
  Launcher() { :; }
  BASE_DIR="$BATS_TEST_TMPDIR/base"
  mkdir -p "$BASE_DIR"
  HDD_IMAGES="$BATS_TEST_TMPDIR/hdd"
  mkdir -p "$HDD_IMAGES/7"
  MacOS_version 7
  status=$?
  [ "$status" -eq 0 ]
  [ "$MACOS_DIR" = "$BASE_DIR/macos7" ]
  [ "$MACOS_CONFIG" = "$BASE_DIR/macos7/macos7.cfg" ]
}

