FROM haskell:8.8.3

ENV RESOLVER lts-15.4

COPY --from=dastapov/hledger:1.18 /usr/bin/hledger* /usr/bin/

COPY ./01-getting-started/export/export.hs /tmp

# Precompile all packages needed for export.hs
RUN stack --resolver $RESOLVER --system-ghc script --package shake --package directory /tmp/export.hs -- -v \
    && rm -r /tmp/export.hs \
    && chmod -R g+wrX,o+wrX /root \
    && apt-get update \
    && apt-get install --yes patchutils gawk csvtool ripgrep fish \
    && rm -rf /var/lib/apt/lists \
    && cd /usr/bin/ \
    && curl -L https://github.com/lotabout/skim/releases/download/v0.8.1/skim-v0.8.1-x86_64-unknown-linux-gnu.tar.gz | tar xz

RUN adduser --system --ingroup root hledger

# This is where the data dir would be mounted to
RUN mkdir full-fledged-hledger
VOLUME full-fledged-hledger

ENV STACK_ROOT /root/.stack
RUN echo "allow-different-user: true" >> /root/.stack/config.yaml
RUN stack setup
RUN chsh -s /usr/bin/fish

USER hledger
WORKDIR full-fledged-hledger
ENV LC_ALL C.UTF-8
ENV SHELL /usr/bin/fish

CMD ["fish"]
