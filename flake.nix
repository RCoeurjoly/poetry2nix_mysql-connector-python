{
  description = "mysql-connector-python tests for Poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      myAppEnv = pkgs.poetry2nix.mkPoetryEnv {
        projectDir = ./.;
        editablePackageSources = {
          my-app = ./src;
        };
      };

      customOverrides = self: super: {
        # Overrides go here
        mysql-connector-python = super.mysql-connector-python.overridePythonAttrs (
          old: {
            preferWheel = true;
          }
        );
      };

      app = pkgs.poetry2nix.mkPoetryApplication {
        projectDir = ./.;
        python = pkgs.python39;
        overrides =
          [ pkgs.poetry2nix.defaultPoetryOverrides customOverrides ];
      };

    in {

      devShells.x86_64-linux.default = myAppEnv.env.overrideAttrs (oldAttrs: {
        buildInputs = with pkgs; [ poetry ];
      });

    };
}
