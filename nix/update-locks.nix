{ lib
, writeShellScriptBin
, gradle
, jq
, xml-to-json
}:

writeShellScriptBin "update-locks" ''
  set -eu -o pipefail
  ${gradle}/bin/gradle lock --write-locks
  ${gradle}/bin/gradle --write-verification-metadata sha256 dependencies
  ${xml-to-json}/bin/xml-to-json -sam -t components gradle/verification-metadata.xml \
    | ${jq}/bin/jq '[
        .[] | .component |
        { group, name, version,
          artifacts: [([.artifact] | flatten | .[] | {(.name): .sha256.value})] | add
        }
      ]' > deps.json
  rm gradle/verification-metadata.xml
''