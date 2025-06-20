require 'rails/railtie'

module AnchorMigrations
  class Railtie < Rails::Railtie
    initializer 'anchor_migrations.configure_rails_initialization' do
      puts "AnchorMigrations Railtie initialized!"
      rails_version_major = Rails::VERSION::MAJOR
      rails_version_minor = Rails::VERSION::MINOR
      puts "Rails app major version #{rails_version_major}"
      puts "Rails app minor version #{rails_version_minor}"
      # You can put any Rails integration setup here
      # For example, configuring middleware, rake tasks, etc.
    end
  end
end

