# Xylem
[![Build Status](https://travis-ci.org/oesgalha/xylem.svg)](https://travis-ci.org/oesgalha/xylem)
[![Code Climate](https://codeclimate.com/github/oesgalha/xylem/badges/gpa.svg)](https://codeclimate.com/github/oesgalha/xylem)
[![Test Coverage](https://codeclimate.com/github/oesgalha/xylem/badges/coverage.svg)](https://codeclimate.com/github/oesgalha/xylem/coverage)
[![Dependency Status](https://gemnasium.com/oesgalha/xylem.svg)](https://gemnasium.com/oesgalha/xylem)

Xylem provides a simple way to store and retrieve hierarchical data in ActiveRecord.

## What

Xylem uses the Adjacency List approach to store hierarchical data, and use [recursive CTEs](https://en.wikipedia.org/wiki/Hierarchical_and_recursive_queries_in_SQL#Common_table_expression) to query through it.

That means that the storage strategy is simple: in order to map an ActiveRecord Model to a tree-like structure with parents and children, it's needed to add only one column to the table which contains a node's parent id. If the node is a root node that column will have a null value (or `nil`). With that, the insertion and removal of nodes is a simple process and thus it should be simple to recover a tree in a corrupted state and guarantee data consistency.

Also queries that traverse the tree (such as get ancestors or descendants of a node) are made in one single recursive SQL statement.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xylem', github: 'oesgalha/xylem'
```

And then execute:

    $ bundle

Now add a `parent_id` column to your ActiveRecord::Base model.
Let's suppose that you want to add the tree behavior to a model called `Menu` with a database table called `menus`.

You could invoke the rails generator tool like this:
```
rails g migration add_parent_to_menus parent:references
```

Or you could create the migration by hand, with something like that:
```ruby
class AddParentToMenus < ActiveRecord::Migration
  def change
    add_reference :menus, :parent, index: true, foreign_key: true
  end
end
```

Some notes regarding migration:
* Add an index is optional, but recommended for performance sake.
* Add a foreign key is optional, but it's recommended to guarantee data consistency
* The `foreign_key: true` option is available in [rails 4.2.1](https://github.com/rails/rails/blob/v4.2.1/activerecord/CHANGELOG.md) or newer

Now you need to enable the tree behavior in or model by adding the `acts_as_tree` directive in it.
Let's suppose again that you're dealing with a model called `Menu`, you should add the following:

```ruby
class Menu < ActiveRecord::Base
  acts_as_tree
end
```

And you are ready to go! Check the config options in the Usage section below.

## Usage

### acts_as_tree options

* :counter_cache => The name of the column that will cache the node children count. In order to use this, you need to create an integer column with the same name (ex: `counter_cache: :children_count`).
* :touch => If `true`, when you updated or destroy a node, it's ancestors will be touched: `updated_at` column is updated with the current time. (the default value is `false`)
* :dependent => Controls what happens with the children of a deleted node. Choose one of the following options (the default value is :destroy)
  * :destroy children are also destroyed.
  * :delete_all delete children direct in the database (this will skip callbacks)
  * :nullify set the children's parent_id to NULL (nil), therefore turning them into new roots (this will also skip callbacks)
  * :restrict_with_exception an exception is raised if there is an attempt to destroy a record with children
  * :restrict_with_error a validation error is added to the record if there is an attempt to destroy it and it has children

### Class methods

Xylem adds the following class methods to a class with the `acts_as_tree` directive:

* `root`: returns the first root of the tree
* `roots`: returns all the roots from the tree
* `leaves`: returns all the leaves from the tree

### Instance methods

Xylem adds the following class methods to a class with the `acts_as_tree` directive:

* `ancestors`: returns the ancestors from root to the parent of the node. Ordered from the root to the parent.
* `self_and_ancestors` returns the ancestors from the root to the node itself. Ordered from the root to the node.
* `descendants` returns all the descendants of the given node. Ordered by depth from the closer to the node to the more distant ones.
* `self_and_descendants` returns the node and all it's descendants. Ordered by depth with the node first and the descendants later.
* `root` returns the current node root.
* `siblings` returns the siblings from the node, excluding itself.
* `self_and_siblings` returns the node and it's siblings.
* `children` returns the direct children of the node.
* `self_and_children` returns the node and it's direct children.
* `parent` returns the node parent.
* `root?` returns true if the current node is a root, false otherwise.
* `leaf?` returns true if the current node is a leaf, false otherwise.

### Examples

```ruby
class Menu < ActiveRecord::Base
  acts_as_tree
end

root = Menu.create!(name: 'root menu')
child1 = root.children.create!('option 1')
child2 = Menu.create!(name: 'option 2', parent: root)
subchild = Menu.create!(name: 'suboption 1', parent: child2)

Menu.roots                  # => [ root ]
Menu.leaves                 # => [ child1, subchild ]

root.root?                  # => true
child1.leaf?                # => true

child2.self_and_descendants # => [ child2, subchild ]

child1.root                 # => root
child1.self_and_ancestors   # => [ root, child1 ]

child1.self_and_siblings    # => [ child1, child2 ]
```

## Dependencies

* ActiveRecord 4+

This gem relies on the `Recursive CTE` feature which was introduced to SQL in the 1999 revision.
So you need a database management system that implements it. This gem is tested against PostgreSQL and SQLite, those started to support the recursive CTE in the following versions:
* PostgreSQL 8.4+
* SQLite 3.8.3+

It seems that MySQL still has no support to it. If you use MySQL you can look for other gems to help you deal with models organized in trees, check the Alternatives section bellow.

This gem is tested against ruby 1.9.3 and newer only.

## Alternatives

There are other gems that allow you to treat models like trees, with different approaches.
Here are some other gems you could use to achieve the same objective:

* [acts_as_tree](https://github.com/amerine/acts_as_tree)
* [awesome_nested_set](https://github.com/collectiveidea/awesome_nested_set)
* [ancestry](https://github.com/stefankroes/ancestry)

## Contributing

1. Fork it ( https://github.com/oesgalha/xylem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Copyright (c) 2015-2016 Oscar Esgalha

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
