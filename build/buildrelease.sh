#!/bin/bash

set -e

cd $(dirname $0)

if [[ $# -ne 1 ]]; then
  echo 'Usage: buildrelease.sh tag'
  echo 'e.g. buildrelease.sh NodaTime.Serialization.JsonNet-2.0.0'
  echo 'or buildrelease.sh NodaTime.Serialization.Protobuf-1.0.0-alpha01'
  echo 'It is expected that a git tag will already exist'
  exit 1
fi

declare -r TAG=$1
declare -r OUTPUT=artifacts

rm -rf releasebuild
git clone https://github.com/nodatime/nodatime.serialization.git releasebuild -c core.autocrlf=input
cd releasebuild
git checkout $TAG

dotnet restore src/NodaTime.Serialization.JsonNet
dotnet restore src/NodaTime.Serialization.Test
dotnet restore src/NodaTime.Serialization.Protobuf

dotnet build -c Release -p:SourceLinkCreate=true src/NodaTime.Serialization.JsonNet
dotnet build -c Release -p:SourceLinkCreate=true src/NodaTime.Serialization.Protobuf
dotnet build -c Release src/NodaTime.Serialization.Test

dotnet run -c Release -p src/NodaTime.Serialization.Test/NodaTime.Serialization.Test.csproj -f netcoreapp1.0
dotnet run -c Release -p src/NodaTime.Serialization.Test/NodaTime.Serialization.Test.csproj -f net451

mkdir $OUTPUT

dotnet pack --no-build -c Release src/NodaTime.Serialization.sln -o $OUTPUT
