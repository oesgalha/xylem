require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'activerecord', require: 'active_record'
  gem 'pg'
  gem 'benchmark-ips'

  case ENV['BENCH_GEM']
  when 'xylem'
    gem 'xylem', path: '..'
  when 'acts_as_tree'
    gem 'acts_as_tree', github: 'amerine/acts_as_tree'
  when 'awesome_nested_set'
    gem 'activesupport', require: 'active_support/core_ext/module/delegation'
    gem 'awesome_nested_set', github: 'collectiveidea/awesome_nested_set'
  when 'ancestry'
    gem 'ancestry', github: 'stefankroes/ancestry'
  else
    fail 'Please provide a environment variable BENCH_GEM with one o the following values: [xylem, acts_as_tree, awesome_nested_set, ancestry]'
  end
end

ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: 'xylem_test', username: 'postgres')
ActiveRecord::Base.connection.execute('DROP SCHEMA public CASCADE; CREATE SCHEMA public;')

case ENV['BENCH_GEM']
when 'xylem'
  class Comment < ActiveRecord::Base
    act_as_tree
    connection.create_table table_name, force: true do |t|
      t.string :payload
      t.integer :parent_id, index: true
    end
  end
when 'acts_as_tree'
  ActiveRecord::Base.send(:include, ActsAsTree)

  class Comment < ActiveRecord::Base
    acts_as_tree
    connection.create_table table_name, force: true do |t|
      t.string :payload
      t.integer :parent_id, index: true
    end
  end
when 'awesome_nested_set'
  class Comment < ActiveRecord::Base
    acts_as_nested_set
    connection.create_table table_name, force: true do |t|
      t.string :payload
      t.integer :parent_id, index: true
      t.integer :lft, index: true
      t.integer :rgt, index: true
    end
  end
when 'ancestry'
  class Comment < ActiveRecord::Base
    has_ancestry
    connection.create_table table_name, force: true do |t|
      t.string :payload
      t.string :ancestry, index: true
    end
  end
end

def recursive_child(par, depth)
  unless depth == 0
    5.times do
      recursive_child(Comment.create!(payload: SecureRandom.hex(128), parent: par), depth - 1)
    end
  end
end

puts 'INSERTING TEST DATA...'

recursive_child(nil, 5)

@comment1 = Comment.roots.first
@comment11 = @comment1.children.sample
@comment111 = @comment11.children.sample
@comment1111 = @comment111.children.sample
@comment11111 = @comment1111.children.sample

Benchmark.ips do |x|
  x.report('insertion') do |times|
    times.times { Comment.create!(parent: @comment111) }
  end
  x.report('parent') do |times|
    times.times { @comment11111.reload.parent }
  end
  x.report('children') do |times|
    times.times { @comment111.reload.children.to_a }
  end
  x.report('roots') do |times|
    times.times { Comment.roots.to_a }
  end
  x.report('ancestors') do |times|
    times.times { @comment11111.reload.ancestors.to_a }
  end
  x.report('descendants') do |times|
    times.times { @comment1.reload.descendants.to_a }
  end
  x.json!("#{ENV['BENCH_GEM']}.json")
end
