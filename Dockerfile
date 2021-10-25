FROM ruby:2.7

WORKDIR /usr/src/app
RUN echo "alias ll='ls -l --color'" >> ~/.bashrc

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:1.11.2
RUN bundle install

COPY . .
