# Have I Been Bloomed?

A simple Bloom filter and server that lets you check user passwords against
the [`Have I Been Pwned 2.0` password database](https://haveibeenpwned.com/Passwords).

The Bloom filter has a size of 1.7 GB with a false positive rate of 1e-6 (i.e. one in one million).
You can either directly check the Bloom filter from your code via the
[Golang](https://github.com/adewes/bloom) or [Python](https://github.com/adewes/flor)
libraries, or run a `hibb` server to check hashed or plaintext passwords.

## Installation

To generate the Bloom filter and build/install the server, simple run the Makefile:

    make

This will download the password database, unzip it, convert it to a Bloom filter
and build the Golang server. You will need about 10.5 GB of space during the
creation of the filter (1.7 GB for the filter alone and 8.8 GB for the 7z
password file, which you can delete after creating the filter).

## Testing

To test your setup with a smaller filter, you can run

    make test

This will build a small test filter with only the first 100 entries from the HIBP database.
Then, you can run

    make run-test

To run a `hibb` server with the small test filter. Running

    curl -i http://localhost:8000/check-sha1?B0399D2029F64D445BD131FFAA399A42D2F8E7DC

should then return a `200` status code. 

## Server Usage

After installation, the `hibb` server can be started as follows:

    hibb

You may also specify a different file location for the Bloom filter using the
`-f` flag, as well as a different bind address (default: `0.0.0.0:8000`)
using the `-b` flag.

The server needs several seconds to load the Bloom filter into memory, as soon
as it's up you can query plaintext passwords (not recommended) or UPPERCASE
SHA-1 values (preferred) via the `/check` and `/check-sha1` endpoints.
Simply pass the value in the query string:

    http://localhost:8000/check?admin
    # the query below should return 200 with the test filter
    http://localhost:8000/check-sha1?B0399D2029F64D445BD131FFAA399A42D2F8E7DC

If the value is in the filter, the server will return a 200 status code,
otherwise a 418 (I'm a teapot). The latter is used to be distinguishable from
a 404 that you might receive for other reaons (e.g. misconfigured servers).

## CLI Usage

You can use the `bloom` command line tool to check SHA-1 values directly
against the filter:

    echo "admin" | tr -d "\n" | sha1sum - | tr [a-z] [A-Z] | awk -F" " '{print $1}' | bloom check pwned-passwords-2.0.bloom

Or interactively:

    bloom -i check pwned-passwords-2.0.bloom
    Interactive mode: Enter a blank line [by pressing ENTER] to exit.
    B0399D2029F64D445BD131FFAA399A42D2F8E7DC
    >B0399D2029F64D445BD131FFAA399A42D2F8E7DC

## Performance

On a Thinkpad 460p, the Golang server manages to process 17.000 requests per
second while also generating and processing the requests via `ab` (Apache Bench).
Performance on a "real" server should be even better. The server requires about
1.7 GB of memory (i.e. the size of the Bloom filter).
