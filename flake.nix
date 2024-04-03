{
  description = "Tiny Erlang VM";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = self.packages.${system}.atomvm;
        packages.atomvm = pkgs.stdenv.mkDerivation rec {
          src = ./.;

          pname = "atomvm";
          version =
            let
              versionFileContents = builtins.readFile (src + /version.cmake);
              lines = nixpkgs.lib.strings.splitString "\n" versionFileContents;

              versionPrefix = "set(ATOMVM_BASE_VERSION \"";
              versionSuffix = "\")";
              hasVersionPrefix = nixpkgs.lib.strings.hasPrefix versionPrefix;
              versionLine = nixpkgs.lib.lists.findFirst hasVersionPrefix null lines;

              version =
                if (versionLine == null)
                then "dev"
                else
                  nixpkgs.lib.pipe versionLine [
                    (nixpkgs.lib.removePrefix versionPrefix)
                    (nixpkgs.lib.removeSuffix versionSuffix)
                  ];
            in
            version;

          nativeBuildInputs = [
            pkgs.cmake
            pkgs.elixir
            pkgs.gperf
            pkgs.erlang
            pkgs.zlib
          ];
          buildInputs = [ pkgs.mbedtls ];
        };
      }
    );
}
