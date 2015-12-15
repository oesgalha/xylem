require 'test_helper'

class ClassMethodsTest < MiniTest::Test
  def setup
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
    end
  end

  def test_root
    product = Category.create!
    service = Category.create!

    assert_equal Category.root, product
  end

  def test_roots
    product = Category.create!
    service = Category.create!

    physical = Category.create!(parent_id: product.id)
    digital = Category.create!(parent_id: product.id)

    training = Category.create!(parent_id: service.id)

    assert_includes Category.roots, product
    assert_includes Category.roots, service

    refute_includes Category.roots, physical
    refute_includes Category.roots, digital
    refute_includes Category.roots, training
  end

  def test_leaves
    product = Category.create!
    service = Category.create!

    physical = Category.create!(parent_id: product.id)
    digital = Category.create!(parent_id: product.id)

    training = Category.create!(parent_id: service.id)
    consultancy = Category.create!(parent_id: service.id)
    hosting = Category.create!(parent_id: service.id)

    assert_includes Category.leaves, physical
    assert_includes Category.leaves, digital
    assert_includes Category.leaves, training
    assert_includes Category.leaves, consultancy
    assert_includes Category.leaves, hosting

    refute_includes Category.leaves, product
    refute_includes Category.leaves, service
  end

  def test_plain_model
    refute_respond_to PlainModel, :root
    refute_respond_to PlainModel, :roots
    refute_respond_to PlainModel, :leaves
  end
end
