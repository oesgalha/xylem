require 'test_helper'

class ClassMethodsTest < MiniTest::Test
  def setup
    @product = Category.create!
    @service = Category.create!
    @physical = Category.create!(parent_id: @product.id)
    @digital = Category.create!(parent_id: @product.id)
    @training = Category.create!(parent_id: @service.id)
    @consultancy = Category.create!(parent_id: @service.id)
    @hosting = Category.create!(parent_id: @service.id)
    @daily_training = Category.create!(parent_id: @training.id)
    @weekly_training = Category.create!(parent_id: @training.id)

    @gibberish = Menu.create!(draft: true)
    @main = Menu.create!
    @option1 = Menu.create!(parent: @main)
    @option2 = Menu.create!(parent: @main, draft: true)
    @option3 = Menu.create!(parent: @main)
    @suboption11 = Menu.create!(parent: @option1)
    @suboption12 = Menu.create!(parent: @option1)
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
    end
  end

  def test_root
    assert_equal @product, Category.root
  end

  def test_scoped_root
    assert_equal @main, Menu.root
  end

  def test_roots
    assert_equal [@product, @service], Category.roots
  end

  def test_scoped_roots
    assert_equal [@main], Menu.roots
  end

  def test_leaves
    assert_equal [@physical, @digital, @consultancy, @hosting, @daily_training, @weekly_training], Category.leaves
  end

  def test_scoped_leaves
    assert_equal [@option3, @suboption11, @suboption12], Menu.leaves
  end

  def test_plain_model
    refute_respond_to PlainModel, :root
    refute_respond_to PlainModel, :roots
    refute_respond_to PlainModel, :leaves
  end
end
