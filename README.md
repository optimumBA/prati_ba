# PratiBa

## Setup

- install Imagemagick using [Homebrew](https://brew.sh) (`brew install imagemagick`)
- install Elixir, Erlang and Node using [mise](https://mise.jdx.dev)
  - install mise using either `curl https://mise.run | sh` or `brew install mise`
  - make sure to activate it
  - run `mise install`
- start PostgreSQL server
- set environment variables in `.env` (see: [.env.sample](.env.sample))
- run `mix setup`
- download UAInspector database with `mix ua_inspector.download`
- start Phoenix server with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Docs

- execute `mix docs --formatter html --open`

It will open documentation in your browser.

## Running tests

- download UAInspector database with `MIX_ENV=tesst mix ua_inspector.download`
- run `mix coveralls` or `mix coveralls.html`

## Contributing

Make sure to execute `make ci` in order to run all the checks before committing the code.
