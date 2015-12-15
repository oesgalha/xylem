require 'minitest/autorun'
require 'minitest/pride'

require 'active_record'
require 'xylem'

ActiveRecord::Base.configurations = YAML::load(ERB.new(IO.read(File.dirname(__FILE__) + "/db/database.yml")).result)
ActiveRecord::Base.establish_connection(:postgres)
ActiveRecord::Base.connection.execute "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

class Human < ActiveRecord::Base

  act_as_tree

  connection.create_table table_name, force: true do |t|
    t.integer :parent_id
  end
end

class PlainModel < ActiveRecord::Base
  connection.create_table table_name, force: true do |t|
    t.string :name
  end
end
