FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y build-essential wget perl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp


RUN wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_1f/openssl-1.0.1f.tar.gz && \
    tar xf openssl-1.0.1f.tar.gz && \
    cd openssl-1.0.1f && \
    ./config --prefix=/usr --openssldir=/etc/ssl && \
    make -j$(nproc) && \
    make install


WORKDIR /demo
RUN openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -nodes -subj "/CN=heartbleed"

RUN export DEMO_PASSWORD="CorrectHorseBatteryStaple"
RUN export API_KEY="sk-demo-12345"


EXPOSE 4433
CMD ["openssl", "s_server", "-cert", "cert.pem", "-key", "key.pem", "-accept", "4433", "-www"]

