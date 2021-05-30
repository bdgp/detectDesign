{
  description = "detectDesign";
  inputs.nixpkgs = {
    type = "indirect";
    id = "nixpkgs";
  };
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.mach-nix = {
    url = "github:DavHau/mach-nix";
  };
  outputs = { self, nixpkgs, flake-utils, mach-nix }:
  flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in 
    with pkgs; rec {
      packages = flake-utils.lib.flattenTree rec {
        detectDesign-poetry = poetry2nix.mkPoetryApplication rec {
          projectDir = ./.;
          nativeBuildInputs = [python3Packages.ipython];
          overrides = poetry2nix.overrides.withDefaults (self: super: { 
            seaborn = super.seaborn.overridePythonAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ [ self.numpy self.scipy self.matplotlib self.pandas ];
            });
          });
        };
        detectDesign = mach-nix.lib."${system}".buildPythonPackage rec {
          pname = "detectDesign";
          version = "1.0";
          src = ./.;
          #matplotlib ~= 3.0.3
          requirements = ''
          numpy ~= 1.17.3
          pandas ~= 1.0.1
          seaborn ~= 0.8.1
          regex ~= 2018.8.29
          '';
          nativeBuildInputs = [python3Packages.ipython];
        };
      };
      defaultPackage = packages.detectDesign-poetry;
    }
  );
}
