{ lib
, stdenv
, jdk
, gradle
, mavenRepo
}:

stdenv.mkDerivation {
  pname = "built-with-gradle";
  version = "0.0";

  src = ../android;
  
  nativeBuildInputs = [ gradle ];
  
  JDK_HOME = "${jdk.home}";
  
  buildPhase = ''
    runHook preBuild
    gradle build \
       --no-daemon --no-build-cache --info --full-stacktrace \
      --warning-mode=all --parallel --console=plain \
      -PnixMavenRepo=file://${mavenRepo}
    runHook postBuild
  '';
  
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r build/dist/* $out
    runHook postInstall
  '';
  
  dontStrip = true;
}
