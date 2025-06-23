# frozen_string_literal: true

module AnchorMigrations
  # Load the Rails environment
  module RailsLoader
    def self.load_rails!
      return unless defined?(Rails) && defined?(Rails.application)

      env_path = File.expand_path("config/environment", Dir.pwd)
      require "#{env_path}.rb" if File.exist?("#{env_path}.rb")
    end
  end
end
