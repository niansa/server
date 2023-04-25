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
			npmDepsHash = "sha256-WYPSYfKHK2Cq02lOl8w8A1TUSnliw06Kq4YocuuIfms=";
			makeCacheWritable = true;
			postPatch = ''
				substituteInPlace package.json --replace 'npx patch-package' '${pkgs.nodePackages.patch-package}/bin/patch-package'
			'';
			installPhase = ''
				runHook preInstall
				set -x
				#remove packages not needed for production, or at least try to...
				npm prune --omit dev --no-save $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}"
			  find node_modules -maxdepth 1 -type d -empty -delete

				mkdir -p $out/node_modules/
				cp -r node_modules/* $out/node_modules/
				cp -r dist/ $out/node_modules/@spacebar
				for i in dist/**/start.js
				do
					makeWrapper ${pkgs.nodejs-slim}/bin/node $out/bin/start-`dirname ''${i/dist\//}` --prefix NODE_PATH : $out/node_modules --add-flags $out/node_modules/@spacebar`dirname ''${i/dist/}`/start.js
				done
				set +x
				substituteInPlace package.json --replace 'dist/' 'node_modules/@spacebar/'
				find $out/node_modules/@spacebar/ -type f -name "*.js" | while read srcFile; do
					echo Patching imports in ''${srcFile/$out\/node_modules\/@spacebar//}...
					substituteInPlace $srcFile --replace 'require("./' 'require(__dirname + "/'
					substituteInPlace $srcFile --replace 'require("../' 'require(__dirname + "/../'
					substituteInPlace $srcFile --replace ', "assets"' ', "..", "assets"'
					#substituteInPlace $srcFile --replace 'require("@spacebar/' 'require("
				done
				set -x
				cp -r assets/ $out/
				cp package.json $out/
				rm -v $out/assets/openapi.json
				#rm -v $out/assets/schemas.json

				#debug utils:
				#cp $out/node_modules/@spacebar/ $out/build_output -r
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
