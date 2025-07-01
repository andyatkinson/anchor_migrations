# frozen_string_literal: true

module AnchorMigrations
  # Create a Rails migration from Anchor Migration SQL
  class InitializerGenerator
    def generate
      filename = "anchor_migrations.rb"
      file = "config/initializers/#{filename}"
      if !File.exist?(file)
        File.write(file, initalizer_template)
        puts "Wrote file: #{file}"
        puts File.read(file)
      end
    end

    def initalizer_template
      <<~TEMPLATE.strip
        AnchorMigrations.configure do |config|
          config.use_strong_migrations = false
        end
      TEMPLATE
    end
  end
end
