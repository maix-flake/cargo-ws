{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    cargo-workspaces-git = {
      url = "github:pksunkara/cargo-workspaces/v0.2.41"; # TODO: update ref to update upstream !
      flake = false;
    };
  };

  outputs = {
    self,
    flake-utils,
    naersk,
    nixpkgs,
    cargo-workspaces-git,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import nixpkgs) {
          inherit system;
        };
        naersk' = pkgs.callPackage naersk {};
        built = naersk'.buildPackage {
          name = "cargo-workspaces";
          src = "${cargo-workspaces-git}/cargo-workspaces";
          nativeBuildInputs = with pkgs; [pkg-config perl];
          buildInputs = with pkgs; [openssl];
        };
      in {
        packages.default = built;
        apps = flake-utils.lib.mkApp {drv = built;};
      }
    );
}
