{ pkgs ? import <nixpkgs> { } }:

with pkgs;

lib.makeScope newScope (self: with self; {
  gradle = callPackage ./gradle.nix { };

  updateLocks = callPackage ./update-locks.nix {
    inherit (haskellPackages) xml-to-json;
  };
    
  buildMavenRepo = callPackage ./maven-repo.nix { };
  
  mavenRepo = buildMavenRepo {
    name = "nix-maven-repo";
    repos = [
      "https://plugins.gradle.org/m2"
      "https://repo1.maven.org/maven2"
    ];
    deps = builtins.fromJSON (builtins.readFile ./deps.json);
  };
  
  builtWithGradle = callPackage ./build.nix { };
})