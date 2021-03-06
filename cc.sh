#!/bin/bash
set -eu

PROJECT="ArchiSteamFarm"
OUT="out"
MSBUILD_ARGS=("/nologo")

BUILD="Release"
CLEAN=0

PRINT_USAGE() {
	echo "Usage: $0 [--clean] [debug/release]"
	exit 1
}

for ARG in "$@"; do
	case "$ARG" in
		release|Release) BUILD="Release" ;;
		debug|Debug) BUILD="Debug" ;;
		--clean) CLEAN=1 ;;
		*) PRINT_USAGE
	esac
done

if ! hash dotnet &>/dev/null; then
	echo "ERROR: dotnet CLI tools are not installed!"
	exit 1
fi

cd "$(dirname "$(readlink -f "$0")")"

if [[ -d ".git" ]] && hash git &>/dev/null; then
	git pull || true
fi

if [[ ! -f "${PROJECT}.sln" ]]; then
	echo "ERROR: ${PROJECT}.sln could not be found!"
	exit 1
fi

if [[ "$CLEAN" -eq 1 ]]; then
	dotnet clean -c "$BUILD" -o "$OUT"
	rm -rf "$OUT"
fi

dotnet restore
dotnet build -c "$BUILD" -o "$OUT" --no-restore "${MSBUILD_ARGS[@]}"

echo
echo "Compilation finished successfully! :)"
