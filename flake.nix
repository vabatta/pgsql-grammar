{
  description = "pgsql-grammar — standalone PostgreSQL TextMate grammar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs;
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "pgsql-grammar";
          version = self.shortRev or self.dirtyShortRev or "dev";
          src = self;
          installPhase = ''
            mkdir -p $out
            cp pgsql.tmLanguage.json $out/
            cp LICENSE $out/
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ nodejs ];

          shellHook = ''
            export SHELL=${pkgs.zsh}/bin/zsh

            echo "pgsql-grammar dev shell"
            echo "  npm test            — run grammar tests"
            echo "  npm run validate    — smoke test grammar against samples"
            echo "  npm run preview     — local Shiki preview at http://localhost:3117"

            if [[ $- == *i* ]]; then
              exec $SHELL
            fi
          '';
        };
      }
    );
}
