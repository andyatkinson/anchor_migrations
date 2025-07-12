# frozen_string_literal: true

require "rails/railtie" if defined?(Rails)

module AnchorMigrations
  # Rails integration
  class Railtie < Rails::Railtie
    initializer "anchor_migrations.configure" do
      AnchorMigrations.configure do |config|
        config.use_strong_migrations ||= false
      end
    end
  end
end
