FROM debian:bookworm-slim AS build

WORKDIR /tmp

COPY README.md ./
COPY pyproject.toml ./
COPY pytlsrpt/ ./pytlsrpt/

# hadolint ignore=DL4006,DL3008
RUN    apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install --no-install-recommends \
         python3-pip \
    && pip3 install \
         --break-system-packages \
         --no-cache-dir \
         --no-deps \
         --no-warn-script-location \
         --root-user-action ignore \
         pyproject.toml \
         . \
    # cleanup unneeded files
    && find /usr/local -type d \( -name 'pyproject_toml*' -o -name '__pycache__' \) -print0 | xargs -0 rm -rf

FROM debian:bookworm-slim

COPY --from=build /usr/local/ /usr/local/
COPY doc/manpages/tlsrpt-*.1 /usr/local/share/man/man1/
COPY docker/cmd /cmd
COPY docker/entrypoint /entrypoint

# hadolint ignore=DL3008
RUN apt-get -y -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install --no-install-recommends \
         libpython3-stdlib \
         man-db \
         python3-minimal \
         ssmtp \
         sqlite3 \
    && apt-get -y -qq clean \
    && rm -rf /var/lib/apt/lists/* \
    #
    && chmod 0555 /cmd \
                  /entrypoint \
    #
    # create a unpriveleged user
    && useradd --no-create-home \
               --shell /usr/sbin/nologin \
               --user-group tlsrpt \
    #
    # install some directories
    && install --directory \
               --owner tlsrpt \
               --group tlsrpt \
         /home/tlsrpt/ \
         /tlsrpt-data/ \
         /tlsrpt-socket/ \
         /var/log/tlsrpt/ \
    && ln -s ../../tlsrpt-data/ /var/lib/tlsrpt \
    #
    # as long as there is no special "all docker logs goes to STDOUT" ...
    && ln -sf /proc/1/fd/1 /var/log/tlsrpt/fetcher.log \
    && ln -sf /proc/1/fd/1 /var/log/tlsrpt/receiver.log \
    && ln -sf /proc/1/fd/1 /var/log/tlsrpt/reporter.log \
    #
    # see https://github.com/sys4/tlsrpt/issues/26
    && chmod 0777 /tlsrpt-socket/ \
    #
    # see https://github.com/sys4/tlsrpt/issues/27
    && ln -s ../local/bin/tlsrpt-fetcher /usr/bin/ \
    #
    # would be better if the receiver implement smtp instead of submission
    # via /usr/sbin/sendmail ...
    && rm -rf /etc/ssmtp/ \
    && install -d /etc/ssmtp/ \
    && ln -sf /tmp/ssmtp.conf /etc/ssmtp/ssmtp.conf \
    && ln -sf /tmp/revaliases /etc/ssmtp/revaliases

CMD ["/cmd"]
ENTRYPOINT ["/entrypoint"]
USER tlsrpt
WORKDIR /home/tlsrpt
