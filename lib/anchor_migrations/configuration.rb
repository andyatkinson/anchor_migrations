# frozen_string_literal: true

module AnchorMigrations
  # Configuration for gem
  class Configuration
    attr_accessor :use_strong_migrations

    def initialize
      @use_strong_migrations = false
    end
  end
end
