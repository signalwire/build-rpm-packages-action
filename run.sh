#!/bin/bash

set -euo pipefail

echo "PWD:${PWD}"
ls -1

git config --global --add safe.directory '*' || true

HASH=`echo $GITHUB_SHA | cut -c1-10`
echo "GITHUB_SHA_SHORT:$HASH"

echo "Environment variables:"
printenv

if [ "$USE_CMAKE" = "true" ]; then
	echo "Running: PACKAGE_RELEASE=$GITHUB_RUN_ID.$HASH cmake . -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX"

	if [ ! -f "CMakeLists.txt" ]; then
		echo "Error: CMakeLists.txt not found in the current working directory."
		exit 1
	fi

	PACKAGE_RELEASE="$GITHUB_RUN_ID.$HASH" cmake . -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX && make package
else
	echo -e "%${INPUT_PACKAGER}\n\n%_topdir /data/rpmbuild\n" > ~/.rpmmacros
	rpmdev-setuptree

	VERSION=`rpm -q --qf "%{VERSION}\n" --specfile $INPUT_PROJECT_NAME.spec | head -1`
	echo "VERSION:$VERSION"

	mkdir -vp $INPUT_PROJECT_NAME-$VERSION
	ls -1 $GITHUB_WORKSPACE/ | grep -v "$INPUT_PROJECT_NAME-$VERSION$" | xargs -rI{} cp -vR {} $GITHUB_WORKSPACE/$INPUT_PROJECT_NAME-$VERSION/
	tar -zcvf $INPUT_PROJECT_NAME-$VERSION.tar.gz $INPUT_PROJECT_NAME-$VERSION
	mv -v $INPUT_PROJECT_NAME-$VERSION.tar.gz /data/rpmbuild/SOURCES/
	cp -v $INPUT_PROJECT_NAME-$VERSION/$INPUT_PROJECT_NAME.spec /data/rpmbuild/SPECS/

	# Replace `Release` value in *.spec while keeping original formatting with consideration of dynamic spaces count.
	sed -i "s/\(Release:\)\([[:space:]]*\)1%{?dist}/\1\2$GITHUB_RUN_ID.$HASH/" /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
	cat /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec

	rpmbuild -ba /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
	mv -v /data/rpmbuild/RPMS/x86_64/*.rpm $GITHUB_WORKSPACE
	mv -v /data/rpmbuild/SRPMS/*.rpm $GITHUB_WORKSPACE
fi

ls -1
