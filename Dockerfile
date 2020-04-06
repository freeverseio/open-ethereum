FROM ubuntu:bionic AS builder
COPY . .
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y build-essential cmake clang curl
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN PATH=$HOME/.cargo/bin:$PATH cargo build --release --features final


FROM ubuntu:bionic
COPY --from=builder /target/release/parity /bin/parity
RUN apt-get update && apt-get dist-upgrade -y && apt-get autoremove && apt-get clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
RUN groupadd -g 1000 parity && useradd -m -u 1000 -g parity -s /bin/sh parity
WORKDIR /home/parity
USER parity
RUN mkdir -p /home/parity/.local/share/io.parity.ethereum/
COPY --from=builder --chown=parity:parity  ./scripts/docker/xdai/spec.json /home/parity/spec.json
EXPOSE 5001 8080 8082 8083 8545 8546 8180 30303/tcp 30303/udp

ENTRYPOINT ["/bin/parity","--chain", "/home/parity/spec.json", "--no-warp", "--jsonrpc-interface", "all"]
