# Have I Been Bloomed?

A simple Bloom filter and server that lets you check user passwords against
the [`Have I Been Pwned 2.0` password database](https://haveibeenpwned.com/Passwords).

The Bloom filter has a size of 1.7 GB with a false positive rate of 1e-6 (i.e. one in one million).
You can either directly check the Bloom filter from your code via the
[Golang](https://github.com/adewes/bloom) or [Python](https://github.com/adewes/flor)
libraries, or run a `hibb` server to check hashed or plaintext passwords.

## Installation

To download the Bloom filter and build/install the server, simple run the Makefile:

    make

This will download the password database, unzip it, convert it to a Bloom filter
and build the Golang server. You will need about 10.5 GB of space during the
creation of the filter (1.7 GB for the filter alone and 8.8 GB for the 7z
password file, which you can delete after creating the filter).

## Server Usage

After installation, the `hibb` server can be started as follows:

    hibb

You may also specify a different file location using the `-f` flag, as well
as a different bind address (default: `0.0.0.0:8000`) using the `-b` flag.

The server needs several seconds to load the Bloom filter in memory, as soon
as it's up you can query both plaintext passwords (not recommended) or UPPERCASE
SHA-1 values (preferred) via the `/check` and `/check-sha1` endpoints.
Simply pass the value in the query string:

    http://localhost:8000/check?admin
    http://localhost:8000/check-sha1?D033E22AE348AEB5660FC2140AEC35850C4DA997

If the value is in the filter, the server will return a 200 status code,
otherwise a 418 (I'm a teapot). The latter is used to be distinguishable from a
a 404 that you might receive for other reaons (e.g. misconfigured servers).

## Performance

On a Thinkpad 460p, the Golang server manages to process 17.000 requests per
second while also generating and processing the requests via `ab` (Apache Bench).
Performance on a "real" server should be even better.