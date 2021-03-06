FROM bitwalker/alpine-elixir-phoenix:1.5.0 as builder

ADD . /app

WORKDIR /app

ENV MIX_ENV=prod

RUN mix do deps.get, deps.compile

RUN npm install
RUN mix do compile, phoenix.digest

RUN mix release

###############################################
FROM alpine:3.6

RUN apk add --no-cache \
      ca-certificates \
      openssl \
      ncurses-libs \
      zlib

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/five9s/releases/0.0.3/five9s.tar.gz /app

ENV MIX_ENV=prod REPLACE_OS_VARS=true

RUN tar -xzf five9s.tar.gz; rm five9s.tar.gz

CMD ["bin/five9s", "foreground"]
