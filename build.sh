#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

case "${1:-default}" in
	default)
		go run build.go
		;;

	clean)
		go run build.go "$1"
		;;

	test)
		go run build.go "$1"
		;;

	tar)
		go run build.go "$1"
		;;

	deps)
		go run build.go "$1"
		;;

	assets)
		go run build.go "$1"
		;;

	xdr)
		go run build.go "$1"
		;;

	translate)
		go run build.go "$1"
		;;

	transifex)
		go run build.go "$1"
		;;

	noupgrade)
		go run build.go -no-upgrade tar
		;;

	all)
		go run build.go test

		go run build.go -goos linux -goarch amd64 tar
		go run build.go -goos linux -goarch 386 tar
		go run build.go -goos linux -goarch armv5 tar
		go run build.go -goos linux -goarch armv6 tar
		go run build.go -goos linux -goarch armv7 tar

		go run build.go -goos freebsd -goarch amd64 tar
		go run build.go -goos freebsd -goarch 386 tar

		go run build.go -goos darwin -goarch amd64 tar

		go run build.go -goos windows -goarch amd64 zip
		go run build.go -goos windows -goarch 386 zip
		;;

	setup)
		echo "Don't worry, just build."
		;;

	test-cov)
		go get github.com/axw/gocov/gocov
		go get github.com/AlekSi/gocov-xml

		echo "mode: set" > coverage.out
		fail=0

		# For every package in the repo
		for dir in $(go list ./...) ; do
			# run the tests
			godep go test -coverprofile=profile.out $dir
			if [ -f profile.out ] ; then
				# and if there was test output, append it to coverage.out
				grep -v "mode: set" profile.out >> coverage.out
				rm profile.out
			fi
		done

		gocov convert coverage.out | gocov-xml > coverage.xml

		# This is usually run from within Jenkins. If it is, we need to
		# tweak the paths in coverage.xml so cobertura finds the
		# source.
		if [[ "${WORKSPACE:-default}" != "default" ]] ; then
			sed "s#$WORKSPACE##g" < coverage.xml > coverage.xml.new && mv coverage.xml.new coverage.xml
		fi
		;;

	*)
		echo "Unknown build command $1"
		;;
esac
