module Xylem
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def roots
      where(parent_id: nil)
    end
  end
end

class ActiveRecord::Base
  def self.act_as_tree
    include Xylem
  end
end
