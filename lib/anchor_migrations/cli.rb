require 'fileutils'

module AnchorMigrations
  class CLI
    def self.start(args)
      command = args.shift

      case command
      when 'init'
        new.init
      when 'generate'
        new.generate
      when 'lint'
        new.lint
      when 'generate_rails_migration'
        new.generate_rails_migration
      else
        puts "Unknown command. Available commands: init"
      end
    end

    def init
      puts "Initializing anchor migrations structure..."

      folders = [
        "anchor_migrations",
        "anchor_migrations/sql",
      ]

      folders.each do |folder|
        if Dir.exist?(folder)
          puts "Directory #{folder} already exists"
        else
          FileUtils.mkdir_p(folder)
          puts "Created directory #{folder}"
        end
      end

      # TODO check for squawk

      puts "Anchor migrations structure initialized."
    end

    def generate
      # TODO accept file name argument
      Generator.new.generate
    end

    def lint
      unless system("which squawk > /dev/null 2>&1")
        abort "Error: 'squawk' command not found in PATH. Installation instructions: <install.txt>."
      end
      system("squawk lint anchor_migrations/sql/*.sql")
    end

    def generate_rails_migration
      RailsMigrationGenerator.new.generate
    end
  end
end
