package main

import (
	"github.com/dcso/bloom"
	"crypto/sha1"
	"net/http"
	"flag"
	"fmt"
	"os"
)

var filter *bloom.BloomFilter

func errorHandler(w http.ResponseWriter, r *http.Request, status int) {
    w.WriteHeader(status)
}

func check(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		errorHandler(w, r, 404)
	}
	s := []byte(fmt.Sprintf("%X", sha1.Sum([]byte(r.URL.RawQuery))))
	if filter.Check(s) {
		w.WriteHeader(200)
	} else {
		w.WriteHeader(418)
	}
}

func checkSHA1(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		errorHandler(w, r, 404)
	}
	if filter.Check([]byte(r.URL.RawQuery)) {
		w.WriteHeader(200)
	} else {
		w.WriteHeader(418)
	}
}

func main() {
	var err error
	filename := flag.String("f", "pwned-passwords-2.0.bloom", "The Bloom filter to load")
	bind := flag.String("b", "0.0.0.0:8000", "The address to which to bind")
	flag.Parse()
	fmt.Printf("Loading Bloom filter from %s...\n", *filename)
	filter, err = bloom.LoadFilter(*filename, true)
	if err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(-1)
	}
	fmt.Printf("Listening on %s...", *bind)
	http.HandleFunc("/check", check)
	http.HandleFunc("/check-sha1", checkSHA1)
    fmt.Fprintln(os.Stderr, http.ListenAndServe(*bind, nil))
}
