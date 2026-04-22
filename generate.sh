#!/usr/bin/env bash
set -e
set -o pipefail
set -x

main() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <data-file.ncl> <output-file>"
    exit 1
  fi

  local script_dir
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  cd "$script_dir" || exit 1

  local data_file
  data_file=$(realpath "$1")
  local output_file
  output_file=$(realpath "$2")

  if [ ! -f "$data_file" ]; then
    echo "error: data file not found: $data_file"
    exit 1
  fi

  if [ "${data_file##*.}" != "ncl" ]; then
    echo "error: expected Nickel data file (*.ncl): $data_file"
    exit 1
  fi

  local output_dir
  output_dir=$(dirname "$output_file")
  if [ ! -d "$output_dir" ]; then
    echo "error: output directory does not exist: $output_dir"
    exit 1
  fi

  nickel export --format text <<Nickel > "$output_file"
let render = import "${script_dir}/template/Dockerfile.ncl" in
let {Schema} = import "${script_dir}/template/schema.ncl" in
let config = import "${data_file}" in
render (config | Schema)
Nickel

}

main "$@"
