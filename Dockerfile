FROM debian:buster@sha256:33a8231b1ec668c044b583971eea94fff37151de3a1d5a3737b08665300c8a0b

RUN apt update -qq && apt upgrade --no-install-recommends -yqq wget
RUN wget --no-check-certificate https://bitcoin.org/bin/bitcoin-core-22.0/bitcoin-22.0-x86_64-linux-gnu.tar.gz
RUN tar zxvf ./bitcoin-22.0-x86_64-linux-gnu.tar.gz
RUN install -m 0755 -o root -g root -t /usr/local/bin bitcoin-22.0/bin/*

RUN apt update -qq && apt upgrade --no-install-recommends -yqq \
  && apt install --no-install-recommends -yqq procps python3-pip uwsgi uwsgi-plugin-python3 python3-setuptools nginx \
    runit tor \
  && mkdir /etc/service/nginx \
  && mkdir /etc/service/wsgi \
  && mkdir /etc/service/bitcoind \
  && mkdir /etc/service/tor \
  && mkdir /var/lib/tor/http_hs \
  && chmod 700 /var/lib/tor/http_hs


COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY torrc /etc/tor/torrc
COPY nginx.runit /etc/service/nginx/run
COPY wsgi.runit /etc/service/wsgi/run
COPY bitcoind.runit /etc/service/bitcoind/run
COPY tor.runit /etc/service/tor/run

WORKDIR /pinserver
COPY runit_boot.sh wsgi.ini requirements.txt wsgi.py server.py lib.py pindb.py __init__.py generateserverkey.py flaskserver.py /pinserver/
RUN pip3 install --upgrade pip wheel
RUN pip3 install --require-hashes -r /pinserver/requirements.txt

CMD ["./runit_boot.sh"]
