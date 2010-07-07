require 'test_helper'

class TagTest < ActiveSupport::TestCase
  # Tag may not be saved empty.
  def test_no_empty_saving
    t = Tag.new
    assert !t.save, 'Do not save empty tag'
  end

  # Tag have to have a user.
  def test_value_uniqueness
    t = tags(:earth)
    c = Tag.new(:value => t.value)
    assert !c.save, 'value should be unique'
  end

  def test_scopes
    t = tags(:earth)
    with_value = Tag.with_value("Earth")
    assert with_value.include?(t), "should find tag with this value (using with_value)"
    with_values = Tag.with_values("Earth","Wind","Fire")
    assert with_values.include?(t), "should find tag with this value (using with_values)"
    with_value_lilke = Tag.with_value_like("Ea")
    assert with_value_lilke.include?(t), "should find tag with this value (using with_value_like)"
    with_values_like = Tag.with_values_like("E","W","F")
    assert with_values_like.include?(t), "should find tag with this value (using with_values_like)"
  end

  def test_insertion
    assert_difference('Tag.count', 1, "should insert 1 value") do
      Tag.find_or_create_with_value_like("captainplanet")
    end
    assert_difference('Tag.count', 0, "should not insert repeated value") do
      Tag.find_or_create_with_value_like("captainplanet")
    end
    assert_difference('Tag.count', 1, "should insert 1 value in german") do
      Tag.find_or_create_with_value_like("kaptainerdbeben",Tag.languages("de").first.id)
    end
    assert_difference('Tag.count', 4, "should insert 4 values") do
      Tag.find_or_create_all_with_values_like("john","paul","george","ringo")
    end
    assert_difference('Tag.count', 4, "should insert 4 values in german") do
      Tag.find_or_create_all_with_values_like("johan","helmut","franz","klaus",Tag.languages("de").first.id)
    end

  end

  def test_equals
    c = tags(:earth)
    t = Tag.new
    t.value = c.value
    assert c==t, "should recognize first tag as equal to second tag"
  end

end