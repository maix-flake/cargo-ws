{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    flake-utils,
    naersk,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import nixpkgs) {
          inherit system;
        };
        cargo_workspace = pkgs.fetchFromGitHub {
          owner = "pksunkara";
          repo = "cargo-workspaces";
          rev = "0da6389eccf4dee585607b72a0f11de9742cc1aa";
          sha256 = "sha256-nOo6nnB7JI5wzOwoo1SRl6c4M9tvlFpr41ebtCm+YBo=";
        };
        naersk' = pkgs.callPackage naersk {};
      in rec {
        # For `nix build` & `nix run`:
        packages.default = naersk'.buildPackage {
          src = "${cargo_workspace}/cargo-workspaces";
          nativeBuildInputs = with pkgs; [pkg-config];
          buildInputs = with pkgs; [openssl];
        };

        # For `nix develop` (optional, can be skipped):
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [rustc cargo];
        };
      }
    );
}
