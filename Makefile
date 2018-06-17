#!/bin/bash

# download pwned passwords file
pwned-passwords-2.0.txt.7z:
	wget https://downloads.pwnedpasswords.com/passwords/pwned-passwords-2.0.txt.7z

# create the Bloom filter
pwned-passwords-2.0.bloom: pwned-passwords-2.0.txt.7z
	bloom --gzip create -p 1e-6 -n 501636842 pwned-passwords-2.0.bloom
	7z x pwned-passwords-2.0.txt.7z -so | awk -F":" '{print $1}' | bloom insert pwned-passwords-2.0.bloom

bloom-filter: pwned-passwords-2.0.bloom

bloom-tool:
	go get github.com/adewes/bloom
	go install github.com/adewes/bloom

server:
	go get ./...
	go install ./...

all: bloom-tool server bloom-filter

.DEFAULT_GOAL := all
