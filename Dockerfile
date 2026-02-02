FROM ruby:3.3.1

RUN apt-get update && apt-get install -y --no-install-recommends sqlite3

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 3000
ENV RAILS_ENV=development
RUN rails assets:precompile
CMD ["rails", "server", "-b", "0.0.0.0"]