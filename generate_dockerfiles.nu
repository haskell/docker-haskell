# Regenerate every data-driven Dockerfile in this repository from the Nickel
# template and per-variant `.ncl` data files.
#
# Skips underscored fragments (e.g. `_globals.ncl`, `_ghc.ncl`,
# `_cabal-install.ncl`) and any GHC line that has no `.ncl` data files
# (9.0, 9.2 are not regenerated at all; 9.4/9.6/9.8 only regenerate
# bullseye and slim-bullseye; 9.10 also regenerates bookworm and
# slim-bookworm — see README §"Generating Dockerfiles").
#
# Returns: the list of generated Dockerfile paths.
#
# Examples:
# > nu ./generate_dockerfiles.nu                       # regenerate everything
# > nu ./generate_dockerfiles.nu --pattern '14'     # only 9.14 variants
# > nu ./generate_dockerfiles.nu --pattern 'bookworm\.ncl$'   # every bookworm variant
# > nu ./generate_dockerfiles.nu --pattern '10/buster'    # exactly one file
#
# See also: README §"Generating Dockerfiles" for the full per-line
# hand-maintained/regenerated split.
def main [
  --pattern (-p): string   # regex matched against data-file paths; filters which `.ncl` files are processed
]: any -> list<string> {
  let only_op = if $pattern != null {
    {|| $in =~ $pattern }
  } else {
    {|| true }
  }
  let datafiles: list<path> = glob ./9.*/[!_]*.ncl | where $only_op
  let template_dir: path = '.' | path join template | path expand

  $datafiles | each { $in | gen-file $template_dir }
}

# Render one data file to `<parent>/<stem>/Dockerfile` using
# `template/Dockerfile.ncl`, with the config validated against
# `template/schema.ncl`.
#
# `template_dir` is the absolute path of the directory containing
# `Dockerfile.ncl` and `schema.ncl` (the repo's `template/` dir).
#
# Returns: the path of the generated Dockerfile.
# The `nickel export` call's stdout is suppressed (`o> /dev/null`);
# `nickel` errors abort the script via the surrounding shell, so a
# non-zero exit is the error signal.
def gen-file [template_dir: path]: path -> string  {
  let parts: table = $in | path parse
  let template: path = $template_dir | path join Dockerfile.ncl
  let schema: path = $template_dir | path join schema.ncl
  let outfile: path = [$parts.parent $parts.stem Dockerfile] | path join

  $"let render = import \"($template)\" in
  let { Schema } = import \"($schema)\" in
  let config = import \"($in)\" in
  render \(config | Schema\)" |
    nickel export --format text --output $outfile o> /dev/null

  $outfile
}
