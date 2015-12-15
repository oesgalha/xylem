require 'test_helper'

class ClassMethodsTest < MiniTest::Test
  def test_roots
    dad = Human.create!
    son = Human.create!(parent_id: dad.id)

    assert_includes Human.roots, dad
  end
end
