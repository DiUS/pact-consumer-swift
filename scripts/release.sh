#!/bin/sh
REMOTE_BRANCH=master
POD_NAME=PactConsumerSwift
PODSPEC=PactConsumerSwift.podspec
RELEASE_NOTES=CHANGELOG.md

POD=${COCOAPODS:-"pod"}

function help {
    echo "Usage: release VERSION RELEASE_NAME DRY_RUN"
    echo
    echo "VERSION should be the version to release, should not include the 'v' prefix"
    echo "RELEASE_NAME should be the type of release 'Bugfix Release / Maintenance Release'"
    echo
    echo "FLAGS"
    echo "  -d  Dry run, won't push anything or publish cocoapods"
    echo
    echo "  Example: ./scripts/release.sh 1.0.0 'Bugfix Release'"
    echo
    exit 2
}

function die {
    echo "[ERROR] $@"
    echo
    exit 1
}

if [ $# -lt 2 ]; then
    help
fi

VERSION=$1
RELEASE_NAME=$2
DRY_RUN=$3
VERSION_TAG="v$VERSION"

echo "-> Verifying Local Directory for Release"

if [ -z "`which $POD`" ]; then
    die "Cocoapods is required to produce a release. Aborting."
fi
echo " > Cocoapods is installed"

echo " > Is this a reasonable tag?"

echo $VERSION_TAG | grep -q "^vv"
if [ $? -eq 0 ]; then
    die "This tag ($VERSION) is an incorrect format. You should remove the 'v' prefix."
fi

echo $VERSION_TAG | grep -q -E "^v\d+\.\d+\.\d+(-\w+(\.\d)?)?\$"
if [ $? -ne 0 ]; then
    die "This tag ($VERSION) is an incorrect format. It should be in 'v{MAJOR}.{MINOR}.{PATCH}(-{PRERELEASE_NAME}.{PRERELEASE_VERSION})' form."
fi

echo " > Is this version ($VERSION) unique?"
git describe --exact-match "$VERSION_TAG" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    die "This tag ($VERSION) already exists. Aborting."
else
    echo " > Yes, tag is unique"
fi

echo " > Generating release notes to $RELEASE_NOTES"
cp $RELEASE_NOTES ${RELEASE_NOTES}.backup
echo "# ${VERSION} - ${RELEASE_NAME}\n" > ${RELEASE_NOTES}.next
LATEST_TAG=`git describe --abbrev=0  --tags --match=v[0-9].[0-9].[0-9]`
git log --pretty='* %h - %s (%an, %ad)' ${LATEST_TAG}..HEAD . >> ${RELEASE_NOTES}.next
cat $RELEASE_NOTES.next | cat - ${RELEASE_NOTES}.backup > ${RELEASE_NOTES}
rm ${RELEASE_NOTES}.next
rm ${RELEASE_NOTES}.backup
git add $RELEASE_NOTES || { die "Failed to add ${RELEASE_NOTES} to INDEX"; }

if [ ! -f "$PODSPEC" ]; then
    die "Cannot find podspec: $PODSPEC. Aborting."
fi
echo " > Podspec exists"

# Verify cocoapods trunk ownership
pod trunk me | grep -q "$POD_NAME" || die "You do not have access to pod repository $POD_NAME. Aborting."
echo " > Verified ownership to $POD_NAME pod"


echo "--- Releasing version $VERSION (tag: $VERSION_TAG)..."

function restore_podspec {
    if [ -f "${PODSPEC}.backup" ]; then
        mv -f ${PODSPEC}{.backup,}
    fi
}

echo "-> Ensuring no differences to origin/$REMOTE_BRANCH"
git fetch origin || die "Failed to fetch origin"
git diff --quiet HEAD "origin/$REMOTE_BRANCH" || die "HEAD is not aligned to origin/$REMOTE_BRANCH. Cannot update version safely"


echo "-> Setting podspec version"
cat "$PODSPEC" | grep 's.version' | grep -q "\"$VERSION\""
SET_PODSPEC_VERSION=$?
if [ $SET_PODSPEC_VERSION -eq 0 ]; then
    echo " > Podspec already set to $VERSION. Skipping."
else
    sed -i.backup "s/s.version *= *\".*\"/s.version      = \"$VERSION\"/g" "$PODSPEC" || {
        restore_podspec
        die "Failed to update version in podspec"
    }

    git add ${PODSPEC} || { restore_podspec; die "Failed to add ${PODSPEC} to INDEX"; }
    git commit -m "chore: Bumping version to $VERSION" || { restore_podspec; die "Failed to push updated version: $VERSION"; }
fi

echo "-> Tagging version"
git tag "$VERSION_TAG" -F "$RELEASE_NOTES" || die "Failed to tag version"

if [ -z "$DRY_RUN" ]; then
    echo "-> Pushing tag to origin"
    git push origin "$VERSION_TAG" || die "Failed to push tag '$VERSION_TAG' to origin"

    if [ $SET_PODSPEC_VERSION -ne 0 ]; then
        git push origin "$REMOTE_BRANCH" || die "Failed to push to origin"
        echo " > Pushed version to origin"
    fi

    echo
    echo "---------------- Released as $VERSION_TAG ----------------"
    echo

    echo
    echo "Pushing to pod trunk..."

    $POD trunk push "$PODSPEC" --allow-warnings
else
    echo "-> Dry run specified, skipping push of new version"
    $POD spec lint "$PODSPEC" --allow-warnings
fi

rm ${PODSPEC}.backup