def main [
  only = null: string # pattern to match files against
  ]: any -> list<string> {
  let only_op = if $only != null {
    {|| $in =~ $only }
  } else {
    {|| true }
  }
  let datafiles: list<path> = glob ./9.*/[!_]*.ncl | where $only_op
  let template_dir: path = '.' | path join template | path expand

  ["Files to process:" ...$datafiles] | each {$in} | str join (char lsep) | print
  $datafiles | each { $in | gen-file $template_dir }
}

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
}