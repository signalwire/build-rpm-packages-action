#!/bin/bash
pwd
ls -l
echo -e "%${INPUT_PACKAGER}\n\n%_topdir /data/rpmbuild\n" > ~/.rpmmacros
rpmdev-setuptree
VERSION=`rpm -q --qf "%{VERSION}\n" --specfile $INPUT_PROJECT_NAME.spec | head -1`

HASH=`echo $REVISION | cut -c1-10`
echo $VERSION
mkdir -p $INPUT_PROJECT_NAME-$VERSION
cp -R $GITHUB_WORKSPACE/* $GITHUB_WORKSPACE/$INPUT_PROJECT_NAME-$VERSION
tar -zcvf $INPUT_PROJECT_NAME-$VERSION.tar.gz $INPUT_PROJECT_NAME-$VERSION
mv $INPUT_PROJECT_NAME-$VERSION.tar.gz /data/rpmbuild/SOURCES/
cp $INPUT_PROJECT_NAME-$VERSION/$INPUT_PROJECT_NAME.spec /data/rpmbuild/SPECS/

sed -i "s/Release:        1%{?dist}/Release:        $GITHUB_RUN_ID.$GITHUB_SHA/g" /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
cat /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
rpmbuild -ba /data/rpmbuild/SPECS/$INPUT_PROJECT_NAME.spec
mv /data/rpmbuild/RPMS/x86_64/*.rpm /data
mv /data/rpmbuild/SRPMS/*.rpm /data
ls -la