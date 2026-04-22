let RecordWithOnlyKeys = fun keys map_contract =>
  std.contract.custom (fun label value =>
    std.contract.check map_contract label value
    |> match {
      'Error err => 'Error err,
      'Ok checked_value =>
        let value_fields = std.record.fields checked_value in
        value_fields
        |> std.array.fold_right
          (fun field_name rest =>
            if std.array.elem field_name keys then
              rest
            else
              'Error { message = "extra field `%{field_name}`" }
          )
          (
            keys
            |> std.array.fold_right
              (fun field_name rest =>
                if std.array.elem field_name value_fields then
                  rest
                else
                  'Error { message = "missing field `%{field_name}`" }
              )
              ('Ok checked_value)
          ),
    }
  )
in

let Asset = {
  sha256sum
    | String
    | doc "Asset SHA256",
  url
    | String
    | optional
    | doc "Asset URL",
}
in

let ArchAssets = RecordWithOnlyKeys ["aarch64", "x86_64"] { _ : Asset }
in
{
  Schema = {
    distro
      | {
        codename
          | String
          | doc "Distribution code name, e.g. trixie or bookworm",
        abbr
          | String
          | doc "Distribution abbreviation, used on https://downloads.haskell.org/",
        image
          | String
          | doc "Docker image identifier",
      },
    ghc
      | {
        version
          | String
          | doc "GHC version number",
        release_key
          | String
          | doc "GPG release key release is signed with via <archive_name>.sig",
        assets
          | ArchAssets,
      },
    cabal_install
      | {
        version
          | String
          | doc "cabal_install version number",
        release_key
          | String
          | doc "GPG release key release is signed with via <archive_name>.sig",
        assets
          | ArchAssets,
      },
    stack
      | {
        version
          | String
          | doc "Stack version number",
        release_key
          | String
          | doc "GPG release key release is signed with via <archive_name>.sig",
        assets
          | ArchAssets
          | doc "Stack binary distribution assets",
      },
  },
}
