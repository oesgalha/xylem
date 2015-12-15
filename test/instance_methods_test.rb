require 'test_helper'

class ClassMethodsTest < MiniTest::Test
  def setup
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
    end
  end

  def test_ancestors
    product = Category.create!
    service = Category.create!

    physical = Category.create!(parent_id: product.id)
    digital = Category.create!(parent_id: product.id)

    training = Category.create!(parent_id: service.id)
    consultancy = Category.create!(parent_id: service.id)
    hosting = Category.create!(parent_id: service.id)

    daily_training = Category.create!(parent_id: training.id)
    weekly_training = Category.create!(parent_id: training.id)

    weekly_training_ancestors = weekly_training.ancestors

    assert_includes weekly_training_ancestors, training
    assert_includes weekly_training_ancestors, service

    refute_includes weekly_training_ancestors, product
    refute_includes weekly_training_ancestors, physical
    refute_includes weekly_training_ancestors, digital
    refute_includes weekly_training_ancestors, consultancy
    refute_includes weekly_training_ancestors, hosting
    refute_includes weekly_training_ancestors, daily_training
    refute_includes weekly_training_ancestors, weekly_training

    assert_equal [training, service], weekly_training_ancestors

    assert_empty product.ancestors
    assert_empty service.ancestors

    digital_ancestors = digital.ancestors

    assert_includes digital_ancestors, product

    refute_includes digital_ancestors, training
    refute_includes digital_ancestors, service
    refute_includes digital_ancestors, physical
    refute_includes digital_ancestors, consultancy
    refute_includes digital_ancestors, hosting
    refute_includes digital_ancestors, daily_training
    refute_includes digital_ancestors, weekly_training
    refute_includes digital_ancestors, digital
  end

  def test_descendants
  end

  def test_self_and_descendants
  end

  def test_root
  end

  def test_siblings
  end

  def test_self_and_siblings
  end

  def test_self_and_children
  end

  def test_self_and_ancestors
  end

  def test_root?
  end

  def test_leaf?
  end
end
