require 'pry'

module Xylem
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module InstanceMethods
    def ancestors
      klass = self.class
      table = klass.arel_table
      ancestors_cte = Arel::Table.new(:ancestors)
      recursive_term = klass.all.arel.where(table[:id].eq(parent_id))
      non_recursive_term = klass.all.arel.join(ancestors_cte).on(table[:id].eq(ancestors_cte[:parent_id]))
      union = recursive_term.union(:all, non_recursive_term)
      as_statement = Arel::Nodes::As.new(ancestors_cte, union)
      klass.find_by_sql(ancestors_cte.project(Arel.star).with(:recursive, as_statement).to_sql, klass.all.bind_values + klass.all.bind_values)
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
