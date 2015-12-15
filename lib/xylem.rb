module Xylem
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def root
      roots.first
    end

    def roots
      where(parent: nil)
    end

    def leaves
      where(arel_table[:id].not_in(arel_table.project([arel_table[:parent_id]]).where(arel_table[:parent_id].not_eq(nil)).distinct))
    end
  end
end

class ActiveRecord::Base
  def self.act_as_tree
    has_many :children, class_name: name, foreign_key: :parent_id
    belongs_to :parent, class_name: name

    include Xylem
  end
end
