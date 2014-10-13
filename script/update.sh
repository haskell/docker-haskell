#!/usr/bin/env awk -f

#### Synopsis
##
## Parse Debian Package file, extract version info, and update Dockerfile ENVs
##
## usage: update.sh pkg1="" … pkgn="" < Packages

## initialize the pkgs array
function init_pkgs () {
  ## for each arg …
  for ( i = 1; i < ARGC; i++ ) {
    ## … if the arg is a variable (i.e., ends in =) …
    if ( ARGV[ i ] ~ /=$/ ) {
      ## … create an entry in the packages array
      pkgs[ gensub( /(.*)=$/, "\\1", 1, ARGV[ i ] ) ] = ""
    }
  }
}

## initialize the state (i.e., current parser node and package name)
function init_state () {
  state[ "node" ] = "package"
  state[ "name" ] = ""
}

## transition between parsing states
function state_next ( name ) {
  switch ( state[ "node" ] ) {
    case "package":
      state[ "node" ] = "version"
      state[ "name" ] = name
      break
    case "version":
      state[ "node" ] = "package"
      state[ "name" ] = ""
      break
    default:
      print "state_next :: ERROR :: invalid state[ \"node\" ]: ", state[ "node" ]
      exit 1
  }
}

## given X.Y.Z1[.Z2 … .Zn]-d return components specified by replacement
function version_parse ( name, version, replacement ) {
  return gensub( /^([^.]*)\.([^.]*)\.(.*)-(.*)$/, replacement, 1, version )
}

## given X.Y.Z1[.Z2 … .Zn]-d return X.Y
function version_major ( name, version ) {
  return version_parse( name, version, "\\1.\\2" )
}

## given X.Y.Z1[.Z2 … .Zn]-d return Z1[.Z2 … .Zn]
function version_minor ( name, version ) {
  return version_parse( name, version, "\\3" )
}

## given X.Y.Z1[.Z2 … .Zn]-d return d
function version_deb_rev ( name, version ) {
  return version_parse( name, version, "\\4" )
}

## update Dockerfile ENVs for a given package name/version pair
function version_update ( name , version ) {
    print name
    print version_major( name, version )
    print version_minor( name, version )
    print version_deb_rev( name, version )
}

function loop () {
  pkgs_url = "http://deb.haskell.org/stable/Packages"
  pkgs_cmd = "curl --silent" " " pkgs_url
  while ((pkgs_cmd | getline) > 0) {
    #### Package State
    ## scan for next token 'Package' at start of line
    if (( state[ "node" ] == "package" ) && ( $0 ~ /^Package/ )) {
      for ( name in pkgs ) {
        if ( $2 ~ name ) {        ## when package name matches input …
          state_next( name )      ## … begin scanning for 'Version'
        }
      }
    }
    #### Version State
    ## scan for next token 'Version' at start of line
    if (( state[ "node" ] == "version" ) && ( $0 ~ /^Version/ )) {
      ## if current version is greater than previously versions …
      if ( $2 > pkgs[ state[ "name" ] ] ) {
        ## … use this new greatest version (i.e., find the max)
        pkgs[ state[ "name" ] ] = $2
      }
      state_next( name )          ## resume scanning for 'Package'
    }
  }
  exit 0
}

## configure context; initialize state
BEGIN {
   FS = ": "                  ## separate input  fields by ": "
  OFS = "="                   ## separate output fields by "="
  init_pkgs()
  init_state()
  loop()
}

## cleanup; exit
END {
  ## update the Dockerfile with new version info for each package
  for ( name in pkgs ) {
    version_update( name, pkgs[ name ] pkgs_sep )
    print
  }
}
