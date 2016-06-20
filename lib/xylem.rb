require 'active_record'

module Xylem
  module InstanceMethods
    def ancestors
      _xylem_query(:id, parent_id, :id, :parent_id, :desc)
    end

    def self_and_ancestors
      _xylem_query(:id, id, :id, :parent_id, :desc)
    end

    def descendants
      _xylem_query(:parent_id, id, :parent_id, :id, :asc)
    end

    def self_and_descendants
      _xylem_query(:id, id, :parent_id, :id, :asc)
    end

    def root
      ancestors.first
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

    def leaves
      descendants.leaves
    end

    private

    def _xylem_query(where_col, where_val, join_lft_col, join_rgt_col, order_stmt)
      rcte = Arel::Table.new(:recusive_cte)
      table = self.class.arel_table
      i_select = table.project([table[Arel.star], Arel::Nodes::As.new(1, Arel::Nodes::SqlLiteral.new('level'))]).where(table[where_col].eq(where_val))
      r_select = table.project([table[Arel.star], Arel::Nodes::SqlLiteral.new('level + 1')]).join(rcte).on(table[join_lft_col].eq(rcte[join_rgt_col]))
      as_stmt = Arel::Nodes::As.new(rcte, i_select.union(:all, r_select))
      self.class.from(Arel::Nodes::TableAlias.new(rcte.project(Arel.star).with(:recursive, as_stmt), self.class.table_name).to_sql).order(level: order_stmt)
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
  def self.acts_as_tree(options = {})
    config = {
      counter_cache: options[:counter_cache] || nil,
      dependent: options[:destroy] || :destroy,
      touch: options[:touch] || false
    }

    has_many :children,
      class_name: name,
      foreign_key: :parent_id,
      dependent: config[:dependent],
      inverse_of: :parent

    belongs_to :parent,
      class_name: name,
      counter_cache: config[:counter_cache],
      touch: config[:touch],
      inverse_of: :children

    extend  Xylem::ClassMethods
    include Xylem::InstanceMethods
  end
end
