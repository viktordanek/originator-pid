{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , self } :
            let
                fun =
                    system :
                        let
                            pkgs = builtins.import nixpkgs { system = system ; } ;
                            lib =
                                { name ? "ORIGINATOR_PID" } :
                                    "--run 'export ${ name }=$( if [ -t 0 ] ; then ${ pkgs.procps }/bin/ps -p ${ builtins.concatStringsSep "" [ "$" "{" "$" "}" ] } -o ppid= | ${ pkgs.findutils }/bin/xargs ; elif [ -p /proc/self/fd/0 ] ; then ${ pkgs.procps }/bin/ps -p $( ${ pkgs.procps }/bin/ps -p ${ builtins.concatStringsSep "" [ "$" "{" "$" "}" ] } -o ppid= ) -o ppid= | ${ pkgs.findutils }/bin/xargs ; elif [ -f /proc/self/fd/0 ] ; then ${ pkgs.procps }/bin/ps -p $( ${ pkgs.procps }/bin/ps -p ${ builtins.concatStringsSep "" [ "$" "{" "$" "}" ] } -o ppid= ) -o ppid= | ${ pkgs.findutils }/bin/xargs ; else ${ pkgs.procps }/bin/ps -p ${ builtins.concatStringsSep "" [ "$" "{" "$" "}" ] } -o ppid= | ${ pkgs.findutils }/bin/xargs ; fi ; )'" ;
                            in
                                {
                                    checks =
                                        {
                                            main =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            ''
                                                                ${ pkgs.coreutils }/bin/echo ${ ( lib { } ) } > $out &&
                                                                    ${ pkgs.coreutils }/bin/cat $out &&
                                                                    ALPHA='${ lib { } }' &&
                                                                    if [ "${ builtins.concatStringsSep "" [ "$" "{" "ALPHA" "}" ] }" != $( ${ pkgs.coreutils }/bin/cat ${ self + "/expected/main.sh" } ) ]
                                                                    then
                                                                        exit 64
                                                                    fi
                                                            '' ;
                                                        name = "main" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}

