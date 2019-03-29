FROM ruby:2.3

# Add nodejs
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# ERLANG
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
RUN wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
RUN apt-key add erlang_solutions.asc

# Install other stable dependencies that don't change often
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  apt-utils nodejs postgresql-client elixir python3-pip python3-setuptools && \
  rm -rf /var/lib/apt/lists/*
  
WORKDIR /opt/app

COPY . .

# Ruby deps
RUN gem install bundler --conservative
RUN bundle install

# Elixir deps
RUN mix local.hex --force
RUN mix deps.get

# Python deps
RUN pip3 install --user pylint

# Node deps
RUN npm install


RUN export PATH=$HOME/.local/bin:$PATH

EXPOSE 3000
ENV PORT="3000"

# Start the main process.
CMD ["bundle", "exec", "puma", "-t", "5:5:", "-p", "${PORT:-3000}", "-e", "${RACK_ENV:-development}"]
