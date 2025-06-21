# frozen_string_literal: true

require_relative "anchor_migrations/rails_loader"
require_relative "anchor_migrations/utility"
require_relative "anchor_migrations/version"
require_relative "anchor_migrations/generator"
require_relative "anchor_migrations/rails_migration_generator"
require_relative "anchor_migrations/cli"
require_relative "anchor_migrations/railtie" if defined?(Rails)

module AnchorMigrations
  class Error < StandardError; end
end
