{ lib
, stdenv
, jdk
, gradle
, mavenRepo
, androidSdk
}:

stdenv.mkDerivation {
  pname = "built-with-gradle";
  version = "0.0";

  src = ../android;
  
  nativeBuildInputs = [ gradle ];
  
  JDK_HOME = "${jdk.home}";
  ANDROID_SDK_ROOT = "${androidSdk}/share/android-sdk";

  
  buildPhase = ''
    runHook preBuild
    gradle build \
       --no-daemon --no-build-cache --info --full-stacktrace \
      --warning-mode=all --parallel --console=plain \
      -PnixMavenRepo=${mavenRepo} \
      -Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_SDK_ROOT/build-tools/30.0.3/aapt2
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
