# TLSRPT in a Container

## Build

```sh
git glone https://github.com/sys4/tlsrpt.git
cd tlsrpt/
docker-compose build
```
## Running the receiver

The receiver MUST run near the MTA. Communicaton between a MTA and `tlsrpt-reciver`
happen over a unix domain socket created by `tlsrpt-reciver`

```sh
docker run --rm -ti -v tlsrpt:/tlsrpt:rw localhost/tlsrpt
```

