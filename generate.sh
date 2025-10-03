#!/usr/bin/env bash
set -e
set -o pipefail

main() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <data-file> <output-file>"
    exit 1
  fi
  local script_dir
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  cd "$script_dir" || exit 1
  local abs_data_file
  abs_data_file=$(realpath "$1")
  local abs_output_file
  abs_output_file=$(realpath "$2")
  local template_path
  template_path=$(realpath ./template/Dockerfile.jinja)
  # run the generator
  pushd generator || exit 1
  stack run -- -t "$template_path" --data-file "$abs_data_file" > "$abs_output_file"
  popd || exit 1
}
main "$@"
