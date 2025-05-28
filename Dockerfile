FROM ruby:3.3.4

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set working directory
WORKDIR /json_schema_validation_builder

# Install gems
COPY Gemfile /json_schema_validation_builder/Gemfile
COPY Gemfile.lock /json_schema_validation_builder/Gemfile.lock
RUN bundle install

# Copy the rest of the application code
COPY . /json_schema_validation_builder

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/bin/
COPY wait-for-it.sh /usr/bin/

# Ensure the entrypoint script is executable
RUN chmod +x /usr/bin/docker-entrypoint.sh /usr/bin/wait-for-it.sh

# Set the entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command
CMD ["rails", "server", "-b", "0.0.0.0"]
