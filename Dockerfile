FROM ruby:2.6.2
WORKDIR /opt/app
COPY . .
RUN bundle install
EXPOSE 9292/tcp
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "9292"]
