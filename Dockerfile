FROM elixir:1.10.3

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV RUSTUP_HOME=/root/.rustup \
    RUSTFLAGS="-C target-feature=-crt-static" \
    CARGO_HOME=/root/.cargo  \
    PATH="/root/.cargo/bin:$PATH"

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs

# Prepare app dir
WORKDIR /app
ENV HOME=/app

# Set app ENV
ENV MIX_ENV=prod

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set temp build args
ARG DATABASE_URL
ARG MAXMIND_LICENSE_KEY
ARG SECRET_KEY_BASE

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# Build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error
COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# Compile app
COPY lib lib
RUN mix compile

COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["bash", "docker-entrypoint.sh"]
CMD ["mix", "phx.server"]
