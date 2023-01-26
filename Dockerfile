# Use an official Elixir runtime as a parent image
# In the future, we can simply use an alpine image 
# along with the binary elixir release
FROM elixir:1.7.3

RUN apt-get update && \
  apt-get install -y postgresql-client

# Create app directory and copy the Elixir project into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force
RUN mix local.rebar

# Get dependencies and compile
RUN mix do deps.get, compile

CMD ["/app/entrypoint.sh"]