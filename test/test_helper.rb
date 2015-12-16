require 'minitest/autorun'
require 'minitest/pride'

require 'active_record'
require 'xylem'

ActiveRecord::Base.configurations = YAML::load_file(File.dirname(__FILE__) + '/db/database.yml')
ActiveRecord::Base.establish_connection(:postgres)
# Reset the database
ActiveRecord::Base.connection.execute 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'

class Category < ActiveRecord::Base
  
  act_as_tree

  connection.create_table table_name, force: true do |t|
    t.integer :parent_id
  end
end

class Menu < ActiveRecord::Base

  act_as_tree

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
