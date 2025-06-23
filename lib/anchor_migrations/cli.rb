# frozen_string_literal: true

require "fileutils"
require "uri"
require "open3"

module AnchorMigrations
  class CLI
    def self.start(args)
      command = args.shift

      case command
      when "help"
        new.help
      when "init"
        new.init
      when "generate"
        new.generate
      when "lint"
        new.lint
      when "backfill"
        new.generate_rails_migration
      when "migrate"
        new.migrate
      else
        new.help
      end
    end

    def init
      puts "Initializing anchor migrations structure..."

      folders = [
        "anchor_migrations",
        "db/migrate" # for Rails
      ]

      folders.each do |folder|
        if Dir.exist?(folder)
          puts "Directory #{folder} already exists"
        else
          FileUtils.mkdir_p(folder)
          puts "Created directory #{folder}"
        end
      end

      # TODO: check for squawk

      puts "Anchor migrations structure initialized."
    end

    def generate
      # TODO: accept file name argument
      Generator.new.generate
    end

    def lint
      # TODO: return unless there's a directory ./anchor_migrations
      unless system("which squawk > /dev/null 2>&1")
        abort "Error: 'squawk' command not found in PATH."
      end
      system("squawk lint anchor_migrations/*.sql")
    end

    def migrate
      anchor_migration_file = Dir["anchor_migrations/*.sql"].max
      version = File.basename(anchor_migration_file).split("_").first
      sql_ddl = File.read(anchor_migration_file)
      cleaned_sql = AnchorMigrations::Utility.cleaned_sql(sql_ddl)
      puts "Applying Version: #{version}"
      puts cleaned_sql

      if !ENV["DATABASE_URL"]
        puts "DATABASE_URL must be set...exiting"
        exit 1
      else
        base_url = URI.parse(ENV["DATABASE_URL"])
        params = {
          options: "-c lock_timeout=2s"
        }
        encoded = URI.encode_www_form(params)
        encoded = encoded.gsub("+", "%20") # remove "+" for Postgres
        conn_string = "#{base_url}?#{encoded}"
        command = %(
          psql #{conn_string} \
            -c '#{cleaned_sql}'
        )
        stdout, stderr, status = Open3.capture3(command)
        puts "STDOUT:\n#{stdout}"
        puts "STDERR:\n#{stderr}"
        if status.success?
          puts "Success!"
          puts "Applied Version: #{version}"
          puts "Run 'anchor backfill' to generate backfill Rails migration"
        end
        puts "Exit code: #{status.exitstatus}"
      end
    end

    def generate_rails_migration
      RailsMigrationGenerator.new.generate
    end

    def help
      puts "Available commands: init, generate, lint, backfill, migrate"
    end
  end
end
