module Xylem
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module InstanceMethods
    def ancestors
      _xylem_query(:id, parent_id, :id, :parent_id)
    end

    def self_and_ancestors
      _xylem_query(:id, id, :id, :parent_id)
    end

    def descendants
      _xylem_query(:parent_id, id, :parent_id, :id)
    end

    def self_and_descendants
      _xylem_query(:id, id, :parent_id, :id)
    end

    def root
      ancestors.last
    end

    def siblings
      self.class.where(parent_id: parent_id).where.not(id: id)
    end

    def self_and_siblings
      self.class.where(parent_id: parent_id)
    end

    def self_and_children
      [self] + children
    end

    def root?
      parent.nil?
    end

    def leaf?
      children.size == 0
    end

    private

    def _xylem_query(where_col, where_val, join_lft_col, join_rgt_col)
      rcte = Arel::Table.new(:recusive_cte)
      self.class.find_by_sql(rcte.project(Arel.star).with(:recursive, Arel::Nodes::As.new(rcte, self.class.all.arel.where(self.class.arel_table[where_col].eq(where_val)).union(:all, self.class.all.arel.join(rcte).on(self.class.arel_table[join_lft_col].eq(rcte[join_rgt_col]))))).to_sql, self.class.all.bind_values + self.class.all.bind_values)
    end
  end

  module ClassMethods
    def root
      roots.first
    end

    def roots
      where(parent: nil)
    end

    def leaves
      t = arel_table
      where(t[:id].not_in(t.project([t[:parent_id]]).where(t[:parent_id].not_eq(nil)).distinct))
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
