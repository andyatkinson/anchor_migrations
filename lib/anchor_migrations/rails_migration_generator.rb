# frozen_string_literal: true

module AnchorMigrations
  class RailsMigrationGenerator
    def initialize
      # TODO improve this
      last_file = Dir["anchor_migrations/sql/*.sql"].sort.last
      @sql_ddl = File.read(last_file)
      @migration_file_suffix = nil
      parse_sql_ddl
    end

    def generate
      # TODO add more operation types
      if @sql_ddl =~ /create index/i
        output_file = "#{migrations_dir}/#{rails_style_timestamp}_#{@migration_file_suffix}.rb"
        File.write(output_file, rails_generate_migration_code)
        puts "Wrote file: #{output_file}"
        puts File.read(output_file)
      end
    end

    private

    def migrations_dir
      subdirs = ["db", "migrate"]
      File.join(subdirs)
    end

    def load_rails!
      return if defined?(Rails) && Rails.application

      env_path = File.expand_path("config/environment", Dir.pwd)
      require "#{env_path}.rb" if File.exist?("#{env_path}.rb")
    end

    def get_rails_version
      load_rails!

      if defined?(Rails) && defined?(Rails::VERSION)
        major = Rails::VERSION::MAJOR
        minor = Rails::VERSION::MINOR
        "#{major}.#{minor}"
      end
    end

    # Try and deduce the operation type
    # TODO add more operation types, only supporting CREATE INDEX for now
    def parse_sql_ddl
      # Case-insensitive regex with optional keywords
      if @sql_ddl =~ /\A
        create\s+index          # "create index" keywords
        (?:\s+concurrently)?    # optional "concurrently"
        (?:\s+if\s+not\s+exists)?  # optional "if not exists"
        \s+(\S+)                # capture index name (non-whitespace)
        \s+on\s+                # "on" keyword
      /xi
        @index_name = $1
        migration_name_from_index = @index_name.split("_").map(&:capitalize).join
        @migration_file_suffix = "create_index_#{@index_name}"
        @migration_name = "CreateIndex#{migration_name_from_index}"
      end
    end

    # Assume it's a concurrently operation for now, disable_ddl_transaction!
    # TODO: support strong_migrations
    def rails_generate_migration_code
      template = <<~MIG_TEMPLATE.strip
        class #{@migration_name} < ActiveRecord::Migration[#{get_rails_version}]
          disable_ddl_transaction!

          def change
            execute <<-SQL
              #{@sql_ddl}
            SQL
          end
        end
      MIG_TEMPLATE
    end

    def rails_style_timestamp
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end
  end
end
