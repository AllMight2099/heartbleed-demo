FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    perl \
    zlib1g-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_1f/openssl-1.0.1f.tar.gz && \
    tar xf openssl-1.0.1f.tar.gz

WORKDIR /build/openssl-1.0.1f

# Configure in a conservative way that works on modern systems
RUN ./config no-shared --prefix=/usr --openssldir=/usr && \
    make depend && \
    make && \
    make install_sw

WORKDIR /demo

RUN openssl version

RUN openssl req -x509 -newkey rsa:2048 \
    -keyout key.pem -out cert.pem -nodes \
    -subj "/CN=heartbleed-demo"

EXPOSE 4433

ENV DEMO_PASSWORD="CorrectHorseBatteryStaple"
ENV API_KEY="sk_demo_123456"
RUN echo "TOP_SECRET=RandomTopSecret" > /demo/secret.txt

CMD ["sh", "-c", "cat /demo/secret.txt >/dev/null && openssl s_server -cert cert.pem -key key.pem -accept 4433 -www -tls1"]

# CMD ["openssl", "s_server", "-cert", "cert.pem", "-key", "key.pem", "-accept", "4433", "-www"]
