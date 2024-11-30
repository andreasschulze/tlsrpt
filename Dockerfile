FROM debian:bookworm-slim AS build

WORKDIR /tmp

COPY README.md ./
COPY pyproject.toml ./
COPY pytlsrpt/ ./pytlsrpt/

# hadolint ignore=DL4006,DL3008
RUN    apt-get -qq update \
    && apt-get -y -qq install --no-install-recommends \
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

# hadolint ignore=DL3008
RUN apt-get -y -qq update \
    && apt-get -y -qq install --no-install-recommends \
         libpython3-stdlib \
         python3-minimal \
    && apt-get -y -qq clean \
    && rm -rf /var/lib/apt/lists/* \
    #
    # create a unpriveleged user
    && useradd --create-home \
               --shell /usr/sbin/nologin \
               --user-group tlsrpt \
    #
    # install some directories
    && install --directory \
               --owner tlsrpt \
               --group tlsrpt \
         /socket \
         /var/lib/tlsrpt/ \
         /var/log/tlsrpt/ \
    #
    # as long as there is no special "all docker logs goes to STDOUT" ...
    && ln -sf /proc/1/fd/1 /var/log/tlsrpt/fetcher.log \
    && ln -sf /proc/1/fd/1 /var/log/tlsrpt/receiver.log \
    && ln -sf /proc/1/fd/1 /var/log/tlsrpt/reporter.log \
    #
    # see https://github.com/sys4/tlsrpt/issues/27
    && ln -s ../local/bin/tlsrpt-fetcher /usr/bin/

ENV TLSRPT_RECEIVER_SOCKETNAME=/socket/tlsrpt-receiver
WORKDIR /tlsrpt
USER tlsrpt
