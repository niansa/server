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
			nativeBuildInputs = with pkgs; [ python3 ];
			npmDepsHash = "$NPM_HASH";
			makeCacheWritable = true;
			postPatch = ''
				substituteInPlace package.json --replace 'npx patch-package' '${pkgs.nodePackages.patch-package}/bin/patch-package'
			'';
			installPhase = ''
				runHook preInstall
				set -x
				mkdir -p $out
				cp -r dist/ $out/
				npm prune --omit dev --no-save $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
			        find node_modules -maxdepth 1 -type d -empty -delete
				cp -r node_modules/ $out/
				mkdir -p $out/node_modules/@fosscord
				for i in $out/dist/**/start.js
				do
					makeWrapper ${pkgs.nodejs-slim}/bin/node $out/bin/start-`dirname ''${i/$out\/dist\//}` --prefix NODE_PATH : $out/node_modules --chdir $out --add-flags $out/`dirname ''${i/$out\//}`/start.js
					#ln -s $out/dist/`dirname ''${i/$out\/dist\//}` $out/node_modules/@fosscord/`dirname ''${i/$out\/dist\//}`
				done
				cp -r dist/* $out/node_modules/@fosscord/
				cp -r assets/ $out/
				cp package.json $out/
				set +x
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
