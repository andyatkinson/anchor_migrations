# frozen_string_literal: true

require "fileutils"
require "uri"
require "open3"

module AnchorMigrations
  # Process command line arguments
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
        AnchorMigrations::DEFAULT_DIR,
        "#{AnchorMigrations::DEFAULT_DIR}/applied",
        "config/initializers",
        "db/migrate"
      ]

      folders.each do |folder|
        if Dir.exist?(folder)
          puts "Directory #{folder} already exists"
        else
          FileUtils.mkdir_p(folder)
          puts "Created directory #{folder}"
        end
      end

      puts "Checking for Squawk"
      check_for_squawk

      puts "Adding initializer"
      InitializerGenerator.new.generate

      puts "Anchor migrations structure initialized."
    end

    def generate
      # TODO: accept file name argument
      Generator.new.generate
    end

    def lint
      unless Dir.exist?(AnchorMigrations::DEFAULT_DIR)
        abort "Error: '#{AnchorMigrations::DEFAULT_DIR}' not found. Did you run anchor init?"
      end
      check_for_squawk
      system("squawk lint #{AnchorMigrations::DEFAULT_DIR}/*.sql")
    end

    def migrate
      # TODO: Only supporting one file for now. Expecting files to be moved into "applied" directory.
      anchor_migration_file = Dir["#{AnchorMigrations::DEFAULT_DIR}/*.sql"].max
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

    private

    def check_for_squawk
      if !system("which squawk > /dev/null 2>&1")
        abort <<~MSG
          "Error: 'squawk' command not found in PATH."
          Is it installed? https://squawkhq.com/docs/
        MSG
      else
        puts "Squawk found."
      end
    end
  end
end
