# frozen_string_literal: true

require "test_helper"

class TestAnchorMigrations < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AnchorMigrations::VERSION
  end

  def test_that_it_has_a_default_dir
    assert_equal ::AnchorMigrations::DEFAULT_DIR, "db/anchor_migrations"
  end
end
