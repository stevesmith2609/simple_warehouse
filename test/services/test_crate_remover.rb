require_relative '../test_helper'
require './app/models/crate'
require './app/models/shelving_unit'
require './app/services/crate_remover'
require './app/services/crate_storer'


class TestCrateRemover < Minitest::Test
  def setup
    @shelving_unit = ShelvingUnit.new(3, 3)
    @crate = Crate.new(1, 0, 2, 1, "P")
    CrateStorer.new(@shelving_unit, @crate).call
  end

  def test_that_valid_crate_is_removed_correctly
    CrateRemover.new(@shelving_unit, @crate).call
    assert_nil @shelving_unit.in_position(1, 0)
    assert_nil @shelving_unit.in_position(2, 0)
  end
end