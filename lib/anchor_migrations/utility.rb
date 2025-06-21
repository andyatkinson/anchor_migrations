# frozen_string_literal: true

module AnchorMigrations
  module Utility
    # Strip out SQL comments that start with
    # double hyphen "--"
    def self.cleaned_sql(input_sql)
      clean_lines = []
      input_sql.lines.each do |line|
        clean_lines << line unless line =~ /^\s*--/
      end
      clean_lines.join
    end
  end
end
