{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d202d4e491a86484220d8fb286445dff3a136e0f.tar.gz") {}
, android ? import (fetchTarball "https://github.com/tadfisher/android-nixpkgs/archive/29bb40c63fea9ab6a27008962c7d8ac57d572f51.tar.gz") {}
}:

with pkgs;

let
  androidSdk = android.sdk (sdkPkgs: with sdkPkgs; [
    cmdline-tools-latest
    build-tools-30-0-3
    platform-tools
    platforms-android-30
    emulator
  ]);

in lib.makeScope newScope (self: with self; {
  inherit androidSdk;

  gradle = gradle_6;

  updateLocks = callPackage ./update-locks.nix {
    inherit (haskellPackages) xml-to-json;
  };
    
  buildMavenRepo = callPackage ./maven-repo.nix { };
  
  mavenRepo = buildMavenRepo {
    name = "nix-maven-repo";
    repos = [
      "https://dl.google.com/dl/android/maven2"
      "https://repo1.maven.org/maven2"
      "https://maven.pkg.jetbrains.space/kotlin/p/kotlin/dev"
      "https://plugins.gradle.org/m2"
    ];
    deps = builtins.fromJSON (builtins.readFile ./deps.json);
  };
  
  builtWithGradle = callPackage ./build.nix { };
})
