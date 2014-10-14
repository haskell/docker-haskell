#!/usr/bin/env awk -f

#### Synopsis ##################################################################
##
## Parse Debian Package file, extract version info, and update Dockerfile ENVs
##
#### usage: ./script/update.sh

#### TODO ######################################################################
##
## * Implement ability to specify upper bounds per-package according to tag
##
####

################################################################################
#### Initialization
################################################################################

## initialize array of pkgs for which we parse version info from Packages file
function init_pkg_str_arr () {
    pkg_str_arr[ 0 ] = "alex"
    pkg_str_arr[ 1 ] = "cabal"
    pkg_str_arr[ 2 ] = "ghc"
    pkg_str_arr[ 3 ] = "happy"
}

## return the names of the repo tag/ver dirs, e.g., 7.8, 7.10, …
function img_tag_get_cmd () {
    return\
            "find . "\
                "-maxdepth 1 "\
                "-type d "\
                "-regex '\\./[[:digit:]][[:digit:].]*' "\
        "| sed 's/^\\.\\///'"
}

## initialize tag array, e.g., dfile_tag_arr[ 0 ] = "7.8"
function init_img_tag_arr () {
    img_tag_idx = 0
    ## run find to get the tags; store the records in the tag array
    while ( ( img_tag_get_cmd() | getline ) > 0 ) {
        img_tag_ver = $0
        img_tag_arr[ img_tag_idx ] = img_tag_ver
        img_tag_idx++
    }
}

## initialize the pkgs array, e.g., pkg_ver_arr[ "7.8:happy" ] = 1.19.4-1
function init_pkg_ver_arr () {
    ## for each tag …
    for ( img_tag_idx in img_tag_arr ) {
        ## … and each pkg name …
        for ( pkg_str_idx in pkg_str_arr ) {
            ## … … init array entry (key is "tag:name") to 0
            pkg_ver_arr[\
                    img_tag_arr[ img_tag_idx ]\
                    ":"\
                    pkg_str_arr[ pkg_str_idx ]\
                ] = "0"
        }
    }
}

## initialize the parsing state
function init_pkg_ver_pst () {
    pkg_ver_pst[ "key_PST_NODE" ] = "node_PACKAGE"  ## current parsing node
    pkg_ver_pst[ "key_PKG_NAME" ] = ""              ## current parsing pkg
}

################################################################################
#### Version Parsing
################################################################################

## given X.Y.Z1[.Z2 … .Zn]-d return requested components
function pkg_ver_cmp_get ( pkg_ver, ver_cmp ) {
    switch ( ver_cmp ) {
        case "MAJOR":
            ## given X.Y.Z1[.Z2 … .Zn]-d return X.Y
            ver_cmp_how = "\\1.\\2"
            break;
        case "MINOR":
            ## given X.Y.Z1[.Z2 … .Zn]-d return .Z1[.Z2 … .Zn]
            ver_cmp_how = ".\\3"
            break;
        case "DEB_REV":
            ## given X.Y.Z1[.Z2 … .Zn]-d return -d
            ver_cmp_how = "-\\4"
            break;
        default:
            print\
                "pkg_ver_cmp_get"\
                " :: ERROR :: invalid component: "\
                ver_cmp
            exit 1
    }
    return gensub( /^([^.]*)\.([^.]*)\.(.*)-(.*)$/, ver_cmp_how, 1, pkg_ver )
}

################################################################################
#### Packages Parsing (State Transition)
################################################################################

## step to the next parsing state
function pkg_ver_pst_next ( pkg_str ) {
    switch ( pkg_ver_pst[ "key_PST_NODE" ] ) {
        ## from PACKAGE node, step to VERSION
        case "node_PACKAGE":
            pkg_ver_pst[ "key_PST_NODE" ] = "node_VERSION"
            pkg_ver_pst[ "key_PKG_NAME" ] = pkg_str
            break
        ## from VERSION node, step to PACKAGE; reset pkg name and start over
        case "node_VERSION":
            pkg_ver_pst[ "key_PST_NODE" ] = "node_PACKAGE"
            pkg_ver_pst[ "key_PKG_NAME" ] = ""
            break
        default:
            print\
                "pkg_ver_"\
                " :: ERROR :: invalid parser state node: "\
                pkg_ver_pst[ "key_PST_NODE" ]
            exit 1
    }
}

## state for parse Package fields
function try_pst_PACKAGE () {
    pfile_entry = $0
    ## scan for 'Package' token at start of line …
    if ( ( pkg_ver_pst[ "key_PST_NODE" ] == "node_PACKAGE" )\
    &&   ( pfile_entry ~ /^Package/ ) ) {
        pfile_pkg_str = $2
        ## … then, for each package we're updating …
        for ( pkg_str_idx in pkg_str_arr ) {
            pkg_str = pkg_str_arr[ pkg_str_idx ]
            ## … … check to see if the current Package entry is relevant …
            if ( pfile_pkg_str ~ pkg_str ) {
                ## … … … if so, we start scanning for 'Version' token
                pkg_ver_pst_next( pkg_str )
            }
        }
    }
}

## state for parsing Version fields
function try_pst_VERSION () {
    pfile_entry = $0
    ## scan for 'Version' token at start of line …
    if ( ( pkg_ver_pst[ "key_PST_NODE" ] == "node_VERSION" )\
    &&   ( pfile_entry ~ /^Version/ ) ) {
        pfile_pkg_ver     = $2
        pfile_pkg_ver_maj = pkg_ver_cmp_get( pfile_pkg_ver, "MAJOR" )
        ## … then, for each tag, e.g., 7.6, 7.8, …
        for ( img_tag_idx in img_tag_arr ) {
            img_tag     = img_tag_arr[ img_tag_idx ]
            pkg_str     = pkg_ver_pst[ "key_PKG_NAME" ]
            pkg_ver_key = img_tag ":" pkg_str
            ## … … if Package pkg version is greater than our version …
            if ( pfile_pkg_ver > pkg_ver_arr[ pkg_ver_key ] ) {
                ## … … … and we're either not parsing a ghc entry or we are
                ## parsing a ghc entry but the Package ghc version is *ONLY*
                ## greater by a MINOR increment …
                if ( ( pkg_str != "ghc" )\
                ||   ( img_tag == pfile_pkg_ver_maj ) ) {
                    # … … … … use this new greater version (i.e., find the max)
                    pkg_ver_arr[ pkg_ver_key ] = pfile_pkg_ver
                }
            }
        }
        pkg_ver_pst_next( "" )      ## resume scanning for 'Package'
    }
}

################################################################################
#### Fetching/Parsing Packages File
################################################################################

## return shell expr used to download Packages from deb.haskell.org
function pfile_get_cmd () {
    curl_cmd = "curl"
    curl_opt = "--silent"
    curl_url = "http://deb.haskell.org/stable/Packages"
    return curl_cmd " " curl_opt " " curl_url
    # return "cat Packages"
}

## fetch Packages from deb.haskell.org and extract pkg version info
function pfile_get_records () {
    ## run curl in a pipe and parse the output
    while ( ( pfile_get_cmd() | getline ) > 0 ) {
        try_pst_PACKAGE()           ## try the PACKAGE parsing state
        try_pst_VERSION()           ## try the VERSION parsing state
    }
}

################################################################################
#### Dockerfile Editing
################################################################################

## return an ENV var string, e.g., MAJOR_GHC
function env_str_mk ( img_tag, pkg_name, ver_cmp_idx, ver_cmp_arr ) {
    return\
        ver_cmp_arr[ ver_cmp_idx ]\
        "_"\
        toupper( pkg_name )
}

## return an ENV var value, e.g., 7.8 (for MAJOR_GHC)
function env_val_mk ( img_tag, pkg_name, ver_cmp_idx, ver_cmp_arr ) {
    return\
        pkg_ver_cmp_get(\
                pkg_ver_arr[ img_tag ":" pkg_name ],\
                ver_cmp_arr[ ver_cmp_idx ]\
            )
}

## return shell expr used to rewrite Dockerfile
function dfile_sed_cmd ( img_tag, env_str, env_val ) {
    sed_bin = "sed"
    sed_opt = "-i ''"
    sed_out = "./" img_tag "/Dockerfile"
    sed_exp =\
        "s/^\\(ENV[[:space:]]\\{1,\\}"\
        env_str\
        "[[:space:]]\\{1,\\}\\)\\(.*\\)$/\\1"\
        env_val\
        "/"
    return sed_bin " " sed_opt " '" sed_exp "' " sed_out
}

## update Dockerfile ENVs for a given package name/version pair
function dfile_tag_rewrite ( img_tag ) {
    ## separators for pretty-printing
    ppr_sep_arr[ 0 ] = "├"
    ppr_sep_arr[ 1 ] = "├"
    ppr_sep_arr[ 2 ] = "└"

    ## ENV var version components
    ver_cmp_arr[ 0 ] = "MAJOR"
    ver_cmp_arr[ 1 ] = "MINOR"
    ver_cmp_arr[ 2 ] = "DEB_REV"

    ## for each pkg name …
    for ( pkg_str_idx in pkg_str_arr  ) {
        pkg_str = pkg_str_arr[ pkg_str_idx ]
        printf "\t* updating %s\n", pkg_str
        ## … and version component
        for ( ver_cmp_idx in ver_cmp_arr ) {
            ## … … calculate the corresponding ENV var str and value
            env_str = env_str_mk( img_tag, pkg_str, ver_cmp_idx, ver_cmp_arr )
            env_val = env_val_mk( img_tag, pkg_str, ver_cmp_idx, ver_cmp_arr )
            ## … … print out the pkg version info about to be rewritten
            printf "\t\t%s%14s => %s\n",\
                ppr_sep_arr[ ver_cmp_idx ],\
                env_str,\
                env_val
            ## … … calc sed cmd; rewrite Dockerfile with the new pkg version
            system( dfile_sed_cmd( img_tag, env_str , env_val ) )
        }
        printf "\n"
    }
}

## rewrite Dockerfile for each tag with updated pkg version info
function dfile_all_rewrite () {
    for ( img_tag_idx in img_tag_arr ) {
        img_tag = img_tag_arr[ img_tag_idx ]
        printf "haskell %s:\n", img_tag
        dfile_tag_rewrite( img_tag )
    }
}

################################################################################
#### Main
################################################################################

function main () {
    init_pkg_str_arr()
    init_img_tag_arr()              ## init tags array (e.g., 7.8, …)
    init_pkg_ver_arr()              ## init packages array
    init_pkg_ver_pst()              ## init parsing state
    pfile_get_records()             ## download Package file; parse records
    dfile_all_rewrite()             ## rewrite Dockerfile with new vers
    exit 0                          ## jump to END
}

################################################################################
#### AWK
################################################################################

## configure context; initialize state
BEGIN {
    FS = ": "                       ## separate input  fields by ": "
   OFS = "="                        ## separate output fields by "="
   main()                           ## start parsing
}

## cleanup; exit
END {
}
