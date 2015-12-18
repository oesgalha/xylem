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

    def self_and_ancestors
      klass = self.class
      table = klass.arel_table
      ancestors_cte = Arel::Table.new(:ancestors)
      recursive_term = klass.all.arel.where(table[:id].eq(id))
      non_recursive_term = klass.all.arel.join(ancestors_cte).on(table[:id].eq(ancestors_cte[:parent_id]))
      union = recursive_term.union(:all, non_recursive_term)
      as_statement = Arel::Nodes::As.new(ancestors_cte, union)
      klass.find_by_sql(ancestors_cte.project(Arel.star).with(:recursive, as_statement).to_sql, klass.all.bind_values + klass.all.bind_values)
    end

    def descendants
      klass = self.class
      table = klass.arel_table
      ancestors_cte = Arel::Table.new(:ancestors)
      recursive_term = klass.all.arel.where(table[:parent_id].eq(id))
      non_recursive_term = klass.all.arel.join(ancestors_cte).on(table[:parent_id].eq(ancestors_cte[:id]))
      union = recursive_term.union(:all, non_recursive_term)
      as_statement = Arel::Nodes::As.new(ancestors_cte, union)
      klass.find_by_sql(ancestors_cte.project(Arel.star).with(:recursive, as_statement).to_sql, klass.all.bind_values + klass.all.bind_values)
    end

    def self_and_descendants
      klass = self.class
      table = klass.arel_table
      ancestors_cte = Arel::Table.new(:ancestors)
      recursive_term = klass.all.arel.where(table[:id].eq(id))
      non_recursive_term = klass.all.arel.join(ancestors_cte).on(table[:parent_id].eq(ancestors_cte[:id]))
      union = recursive_term.union(:all, non_recursive_term)
      as_statement = Arel::Nodes::As.new(ancestors_cte, union)
      klass.find_by_sql(ancestors_cte.project(Arel.star).with(:recursive, as_statement).to_sql, klass.all.bind_values + klass.all.bind_values)
    end

    def root
      klass = self.class
      table = klass.arel_table
      ancestors_cte = Arel::Table.new(:ancestors)
      recursive_term = klass.all.arel.where(table[:id].eq(parent_id))
      non_recursive_term = klass.all.arel.join(ancestors_cte).on(table[:id].eq(ancestors_cte[:parent_id]))
      union = recursive_term.union(:all, non_recursive_term)
      as_statement = Arel::Nodes::As.new(ancestors_cte, union)
      klass.find_by_sql(ancestors_cte.project(Arel.star).with(:recursive, as_statement).where(ancestors_cte[:parent_id].eq(nil)).take(1).to_sql, klass.all.bind_values + klass.all.bind_values).first
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
