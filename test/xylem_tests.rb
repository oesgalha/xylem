require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'minitest/autorun'
require 'minitest/pride'

require 'xylem'

case ENV['DB']
when 'sqlite'
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
when 'postgres'
  ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: 'xylem_test', username: 'postgres')
  ActiveRecord::Base.connection.execute('DROP SCHEMA public CASCADE; CREATE SCHEMA public;')
else
  fail 'Please provide a environment varible DB with either "postgres" or "sqlite" to define the tested database'
end

class Category < ActiveRecord::Base
  acts_as_tree
  connection.create_table table_name, force: true do |t|
    t.integer :parent_id
  end
end

class Menu < ActiveRecord::Base
  acts_as_tree
  default_scope { where(draft: false) }
  connection.create_table table_name, force: true do |t|
    t.integer :parent_id
    t.boolean :draft, default: false
  end
end

class PlainModel < ActiveRecord::Base
  connection.create_table table_name, force: true do |t|
    t.string :name
  end
end

class XylemTestCase < MiniTest::Test
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
    @suboption21 = Menu.create!(parent: @option2, draft: true)
  end

  def teardown
    ar_connection = ActiveRecord::Base.connection
    ar_connection.tables.each { |t| ar_connection.execute "DELETE FROM #{t}" }
  end
end

class ClassMethodsTest < XylemTestCase
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

class InstanceMethodsTest < XylemTestCase
  def test_ancestors
    assert_equal [@service, @training], @weekly_training.ancestors
    assert_equal [@product], @digital.ancestors
    assert_empty @product.ancestors
    assert_empty @service.ancestors
  end

  def test_scoped_ancestors
    assert_equal [@main, @option1], @suboption12.ancestors
    assert_empty @main.ancestors
    assert_empty @gibberish.ancestors
  end

  def test_self_and_ancestors
    assert_equal [@service, @training, @weekly_training], @weekly_training.self_and_ancestors
    assert_equal [@product, @digital], @digital.self_and_ancestors
    assert_equal [@product], @product.self_and_ancestors
    assert_equal [@service], @service.self_and_ancestors
  end

  def test_scoped_self_and_ancestors
    assert_equal [@main, @option1, @suboption12], @suboption12.self_and_ancestors
    assert_equal [@main], @main.self_and_ancestors
    assert_empty @gibberish.self_and_ancestors
  end

  def test_descendants
    assert_equal [@physical, @digital], @product.descendants
    assert_equal [@training, @consultancy, @hosting, @daily_training, @weekly_training], @service.descendants
    assert_equal [@daily_training, @weekly_training], @training.descendants
    assert_empty @physical.descendants
    assert_empty @consultancy.descendants
  end

  def test_scoped_descendants
    assert_equal [@option1, @option3, @suboption11, @suboption12], @main.descendants
    assert_equal [@suboption11, @suboption12], @option1.descendants
    assert_empty @gibberish.descendants
    assert_empty @suboption11.descendants
    assert_empty @suboption21.descendants
  end

  def test_self_and_descendants
    assert_equal [@physical, @digital], @product.descendants
    assert_equal [@training, @consultancy, @hosting, @daily_training, @weekly_training], @service.descendants
    assert_equal [@daily_training, @weekly_training], @training.descendants
    assert_empty @physical.descendants
    assert_empty @consultancy.descendants
  end

  def test_scoped_self_and_descendants
    assert_equal [@main, @option1, @option3, @suboption11, @suboption12], @main.self_and_descendants
    assert_equal [@option1, @suboption11, @suboption12], @option1.self_and_descendants
    assert_equal [@suboption11], @suboption11.self_and_descendants
    assert_empty @gibberish.self_and_descendants
  end

  def test_root
    assert_equal @service, @weekly_training.root
    assert_equal @product, @digital.root
    refute @product.root
  end

  def test_scoped_root
    assert_equal @main, @suboption11.root
    assert_equal @main, @option3.root
    refute @main.root
  end

  def test_siblings
    assert_equal [@digital], @physical.siblings
    assert_equal [@training, @hosting], @consultancy.siblings
  end

  def test_scoped_siblings
    assert_equal [@option3], @option1.siblings
    assert_equal [@suboption11], @suboption12.siblings
  end

  def test_self_and_siblings
    assert_equal [@physical, @digital], @physical.self_and_siblings
    assert_equal [@training, @consultancy, @hosting], @consultancy.self_and_siblings
  end

  def test_scoped_self_and_siblings
    assert_equal [@option1, @option3], @option1.self_and_siblings
    assert_equal [@suboption11, @suboption12], @suboption12.self_and_siblings
  end

  def test_children
    assert_equal [@physical, @digital], @product.children
    assert_equal [@daily_training, @weekly_training], @training.children
  end

  def test_scoped_children
    assert_equal [@option1, @option3], @main.children
    assert_equal [@suboption11, @suboption12], @option1.children
  end

  def test_self_and_children
    assert_equal [@product, @physical, @digital], @product.self_and_children
    assert_equal [@training, @daily_training, @weekly_training], @training.self_and_children
  end

  def test_scoped_self_and_children
    assert_equal [@product, @physical, @digital], @product.self_and_children
    assert_equal [@training, @daily_training, @weekly_training], @training.self_and_children
  end

  def test_root?
    assert @product.root?
    assert @main.root?
    refute @physical.root?
    refute @option3.root?
  end

  def test_leaf?
    assert @daily_training.leaf?
    assert @consultancy.leaf?
    assert @suboption12.leaf?
    assert @option3.leaf?
    refute @service.leaf?
    refute @training.leaf?
    refute @option1.leaf?
  end
end
