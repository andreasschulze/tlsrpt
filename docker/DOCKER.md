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

The Container uses two volumes. One with the socket and a second one persist
the database files.

## Running the reporter

This mode is active if ENV[MODE] is set to `reporter`.

```sh
docker-compose up -d tlsrpt-reporter
```

The Container uses one volume to persist database files. Also, the following
environment settings are required:

* `SSMTP_MAILHUB`

* `TLSRPT_REPORTER_CONTACT_INFO`

* `TLSRPT_REPORTER_ORGANIZATION_NAME`

* `TLSRPT_REPORTER_SENDER_ADDRESS`

## Debugging

The image contains the [Debian package `sqlite3`](https://packages.debian.org/stable/sqlite3)
for debugging purposes. It SHOULD be removed in a production grade environment.

For example, use the following command to dump the
receivers' database:

```sh
echo .dump | sqlite3 /tlsrpt-data/receiver.sqlite
```
