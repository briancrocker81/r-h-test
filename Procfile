web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
worker: bundle exec sidekiq -e $RACK_ENV -C config/sidekiq.yml
