#!/bin/bats

setup() {
  if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    export BATS_LIB_PATH=${BATS_LIB_PATH:-"/usr/lib"}
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file
    bats_load_library bats-detik/detik.bash
  else
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
  fi

  # Common setup for both environments
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  PATH="$DIR/../src:$PATH"

  CONFIG_FILE="$(cd "$DIR/.." >/dev/null 2>&1 && pwd)/examples/config.json"

  export CONFIG_FILE
  export DRY_RUN=1
  export QUIET_MODE=1
}

@test "Check window class matching rules" {
  run nata.sh -class code-oss
  assert_output "code-oss, *, vs_code"
  assert_success

  run nata.sh -class Vivaldi
  assert_output "Vivaldi, *, false"
  assert_failure
}

@test "Check window title matching rules" {
  run nata.sh -title "index.html - Code - OSS"
  assert_output "*, index.html - Code - OSS, lang_html"
  assert_success

  run nata.sh -title "VLC media player"
  assert_output "*, VLC media player, null"
  assert_failure
}

@test "Check window class and title matching rules" {
  run nata.sh -class Steam -title Library
  assert_output "Steam, Library, gaming"
  assert_success

  run nata.sh -class "org.inkscape.Inkscape" -title "New document 1 - Inkscape"
  assert_output "Inkscape, New document, null"
  assert_failure
}

@test "Check regex pattern matching rules" {
  run nata.sh -class "obs"
  assert_output "^obs$, *, streaming"
  assert_success

  run nata.sh -title "Mozilla Firefox - Home"
  assert_output "*, ^Mozilla, null"
  assert_failure
}

@test "Check escaped regex pattern matching" {
  run nata.sh -class "nvim" -title "nvim - [Scratch]"
  assert_output "nvim, nvim - \\[Scratch], vim_scratch"
  assert_success
}

@test "Check fallback rule" {
  run nata.sh -class Firefox
  assert_output "*, *, BaseLayer"
  assert_success
}
