require 'active_support'
require 'active_support/core_ext'
require 'webrick'
require_relative '../lib/controller_base'
require_relative '../lib/SQLObject'
require_relative '../lib/router'


class House < SQLObject
  has_many :humans
end

class Human < SQLObject
  @table_name = "humans"
  has_many( :cats,
  class_name: "Cat",
  foreign_key: :owner_id,
  primary_key: :id
  )
  has_many :walkings
  has_many_through :dogs, :walkings, :dog
end

class Cat < SQLObject
  belongs_to(:owner,
    class_name: "Human",
    foreign_key: :owner_id,
    primary_key: :id
    )
end
class Dog < SQLObject
  has_many :walkings
  has_many_through :humans, :walkings, :human
end

class Walking <SQLObject
  belongs_to :dog
  belongs_to :human
end
