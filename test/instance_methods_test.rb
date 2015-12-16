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

    assert_equal [training, service], weekly_training.ancestors
    assert_equal [product], digital.ancestors

    assert_empty product.ancestors
    assert_empty service.ancestors
  end

  def test_scoped_ancestors
    gibberish = Menu.create!(draft: true)
    main = Menu.create!

    option1 = Menu.create!(parent: main)
    option2 = Menu.create!(parent: main, draft: true)
    option3 = Menu.create!(parent: main)

    suboption11 = Menu.create!(parent: option1)
    suboption12 = Menu.create!(parent: option1)

    suboption21 = Menu.create!(parent: option2)

    assert_equal [option1, main], suboption12.ancestors

    assert_empty suboption21.ancestors
    assert_empty main.ancestors
    assert_empty gibberish.ancestors
  end

  def test_self_and_ancestors
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

  def test_root?
  end

  def test_leaf?
  end
end
