FROM ruby:2.6.2-alpine
WORKDIR /opt/app
COPY app .
RUN bundle install
EXPOSE 80/tcp
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "80"]
