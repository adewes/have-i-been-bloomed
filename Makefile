#!/bin/bash

N := 501636842

# download pwned passwords file
pwned-passwords-sha1-ordered-by-hash-v8.7z:
	wget https://downloads.pwnedpasswords.com/passwords/pwned-passwords-sha1-ordered-by-hash-v8.7z

test-filter:
	bloom --gzip create -p 1e-6 -n 100 pwned-passwords-8.0.bloom.test.gz
	7z x pwned-passwords-sha1-ordered-by-hash-v8.7z -so | awk -F":" '{print $$1}' | head -n 100 | bloom --gzip insert pwned-passwords-8.0.bloom.test.gz

# create the Bloom filter
pwned-passwords-8.0.bloom.gz: pwned-passwords-sha1-ordered-by-hash-v8.7z
	bloom --gzip create -p 1e-6 -n ${N} pwned-passwords-8.0.bloom.gz
	7z x pwned-passwords-sha1-ordered-by-hash-v8.7z -so | awk -F":" '{print $$1}' | bloom --gzip insert pwned-passwords-8.0.bloom.gz

bloom-filter: pwned-passwords-8.0.bloom.gz

bloom-tool:
	go get github.com/DCSO/bloom
	go install github.com/DCSO/bloom/bloom

test: bloom-tool server test-filter

run:
	hibb

run-test:
	hibb -f pwned-passwords-8.0.bloom.test.gz

server:
	go get ./...
	go install ./...

all: bloom-tool server bloom-filter

.DEFAULT_GOAL := all
