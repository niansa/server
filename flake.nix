{
  description = "Spacebar server, written in Typescript.";

  #inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:lilyinstarlight/nixpkgs/unheck/nodejs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
	let
		pkgs = import nixpkgs {
			inherit system;
		};
	in rec {
		packages.default = pkgs.buildNpmPackage {
			pname = "spacebar-server-ts";
			src = ./.;
			name = "spacebar-server-ts";
			#buildInputs = with pkgs; [ ];
			npmDepsHash = "sha256-xPDo1gyeTI40x/F0ZPcwA+XlLWL4kQUSlQAQxbQu0tU=";
			makeCacheWritable = true;
			installPhase = ''
				runHook preInstall
				cp -r dist $out/
				runHook postInstall
			'';
		};
		devShell = pkgs.mkShell {
			buildInputs = with pkgs; [
				nodejs
				nodePackages.typescript
			];
		};
	}
    );
}
