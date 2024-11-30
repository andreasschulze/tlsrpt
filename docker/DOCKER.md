# TLSRPT in a Container

## Build

```sh
git glone https://github.com/sys4/tlsrpt.git
cd tlsrpt/
docker-compose build
```

## Running

The Container may run in different modes selected by ENV[MODE]
By default, if ENV[MODE] is unset, a shell is executed.

## Running the receiver

This mode is active if ENV[MODE] is set to `receiver`.

The receiver MUST run near the MTA. Communication between a MTA and `tlsrpt-reciver`
happen over a unix domain socket created by `tlsrpt-reciver`

```sh
docker-compose up -d tlsrpt-receiver
```

The Container exports two volumes. One with the socket and a second one holding
the database files.
