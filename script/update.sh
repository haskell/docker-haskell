#!/usr/bin/env awk -f

#### Synopsis ##################################################################
##
## Parse Debian Package file, extract version info, and update Dockerfile ENVs
##
#### usage: ./script/update.sh

#### TODO ######################################################################
##
## * Needs to be generalized to handle multiple versions of GHC
##
####

################################################################################
#### Initialization
################################################################################

## initialize the pkgs array
function init_pkgs () {
    pkgs[ "alex"  ] = ""
    pkgs[ "cabal" ] = ""
    pkgs[ "ghc"   ] = ""
    pkgs[ "happy" ] = ""
}

## initialize the state (i.e., current parser node and package name)
function init_state () {
    state[ "node" ] = "package"
    state[ "name" ] = ""
}

################################################################################
#### Version Parsing
################################################################################

## given X.Y.Z1[.Z2 … .Zn]-d return requested components
function version_parse ( name, version, component ) {
    switch ( component ) {
        case "MAJOR":
            ## given X.Y.Z1[.Z2 … .Zn]-d return X.Y
            replacement = "\\1.\\2"
            break;
        case "MINOR":
            ## given X.Y.Z1[.Z2 … .Zn]-d return .Z1[.Z2 … .Zn]
            replacement = ".\\3"
            break;
        case "DEB_REV":
            ## given X.Y.Z1[.Z2 … .Zn]-d return -d
            replacement = "-\\4"
            break;
        default:
            print "version_parse :: ERROR :: invalid component: ", component
            exit 1
    }
    return gensub( /^([^.]*)\.([^.]*)\.(.*)-(.*)$/, replacement, 1, version )
}

## update Dockerfile ENVs for a given package name/version pair
function version_update ( name , version ) {
    ## set up sed cmd to update Dockerfile
    sed_cmd = "sed"
    sed_opt = "-i ''"
    sed_out = "./7.8/Dockerfile"    ## see TODO above regarding hardcoded 7.8

    ## initialize components array
    components[0] = "MAJOR"
    components[1] = "MINOR"
    components[2] = "DEB_REV"

    ## for each component
    for ( i in components ) {
        ## create a sed expression to update the ENV in the Dockerfile
        sed_exp =\
            "s/^\\(ENV[[:space:]]\\{1,\\}"\
            components[i]\
            "_"\
            toupper(name)\
            "[[:space:]]\\{1,\\}\\)\\(.*\\)$/\\1"\
            version_parse( name, version, components[i] )\
            "/"
        ## create the shell expression
        sed_run = sed_cmd " " sed_opt " '" sed_exp "' " sed_out
        ## run the sed command
        system( sed_run )
    }
}

################################################################################
#### Packages Parsing (State Transition)
################################################################################

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

## state for parse Package fields
function state_package () {
    ## scan for next token 'Package' at start of line
    if (( state[ "node" ] == "package" ) && ( $0 ~ /^Package/ )) {
        for ( name in pkgs ) {
            if ( $2 ~ name ) {      ## when package name matches input …
                state_next( name )  ## … begin scanning for 'Version'
            }
        }
    }
}

## state for parsing Version fields
function state_version () {
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

################################################################################
#### Main
################################################################################

function main () {
    ## set up curl cmd to grab Packages from the Haskell repository
    curl_cmd = "curl"
    curl_opt = "--silent"
    curl_url = "http://deb.haskell.org/stable/Packages"
    curl_run = "curl" " " curl_opt " " curl_url

    ## run curl in a pipe and parse the output
    while ((curl_run | getline) > 0) {
        state_package()             ## try the Package parsing state
        state_version()             ## try the Version parsing state
    }

    ## update the Dockerfile with new version info for each package
    for ( name in pkgs ) {
        version_update( name, pkgs[ name ] )
    }

    exit 0                          ## jump to END
}

################################################################################
#### AWK
################################################################################

## configure context; initialize state
BEGIN {
    FS = ": "                       ## separate input  fields by ": "
   OFS = "="                        ## separate output fields by "="
   init_pkgs()                      ## init pkgs array
   init_state()                     ## init parsing state
   main()                           ## start parsing
}

## cleanup; exit
END {
}
