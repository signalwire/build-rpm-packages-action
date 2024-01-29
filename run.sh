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

	PACKAGE_RELEASE="$GITHUB_RUN_ID.$HASH" cmake . -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX && make package
else
	echo -e "%${INPUT_PACKAGER}\n\n%_topdir /data/rpmbuild\n" > ~/.rpmmacros
	rpmdev-setuptree

	VERSION=`rpm -q --qf "%{VERSION}\n" --specfile $INPUT_PROJECT_NAME.spec | head -1`
	echo "VERSION:$VERSION"

	mkdir -vp $INPUT_PROJECT_NAME-$VERSION
	cp -vR $GITHUB_WORKSPACE/* $GITHUB_WORKSPACE/$INPUT_PROJECT_NAME-$VERSION
	tar -zcvf $INPUT_PROJECT_NAME-$VERSION.tar.gz $INPUT_PROJECT_NAME-$VERSION
	mv -v $INPUT_PROJECT_NAME-$VERSION.tar.gz /data/rpmbuild/SOURCES/
	cp -v $INPUT_PROJECT_NAME-$VERSION/$INPUT_PROJECT_NAME.spec /data/rpmbuild/SPECS/

	sed -i "s/Release:        1%{?dist}/Release:        $GITHUB_RUN_ID.$HASH/g" /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
	cat /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec

	rpmbuild -ba /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
	mv -v /data/rpmbuild/RPMS/x86_64/*.rpm $GITHUB_WORKSPACE
	mv -v /data/rpmbuild/SRPMS/*.rpm $GITHUB_WORKSPACE
fi

ls -1
