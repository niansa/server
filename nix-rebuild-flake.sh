#!/usr/bin/env nix-shell
#!nix-shell -i "bash -x" -p nodejs nodePackages.ts-node prefetch-npm-deps bash
DEPS_HASH=`prefetch-npm-deps package-lock.json`
sed 's/$NPM_HASH/'${DEPS_HASH/\//\\\/}'/g' flake.template.nix > flake.nix
