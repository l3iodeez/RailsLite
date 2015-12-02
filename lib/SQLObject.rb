require_relative 'db_connection'
require_relative 'assoc_options'

require 'active_support/inflector'

class SQLObject

  def self.belongs_to(name, options = {})
    options_obj = BelongsToOptions.new(name, options)

    self.assoc_options[name] = options_obj

    define_method(name) do
      parent_class = options_obj.model_class
      f_key = self.send(options_obj.foreign_key)
      parent = parent_class.where({:id => f_key })
      return nil if parent.count < 1
      parent.first
    end
  end

  def self.has_many(name, options = {})
    options_obj = HasManyOptions.new(name, self, options)

    define_method(name) do
      target_class = options_obj.model_class
      p_key_value = self.send(options_obj.primary_key)
      f_key = options_obj.foreign_key
      options_obj.model_class.where({ f_key => p_key_value })
    end

  end

  def self.has_many_through(name, through_name, source_name)
    define_method(name) do
      self.send(through_name).map { |through_obj| through_obj.send(source_name)}
    end

  end

  def self.has_one_through(name, through_name, source_name)
      define_method(name.to_sym) do
        self.send(through_name).send(source_name)
      end

  end

  def self.assoc_options
    @assoc_options ||= {}
  end



  def self.where(params)
    where_string = params.keys.inject("") { |acc, key| acc + "#{key} = ? AND "}
    where_string = where_string[0...-5]

    parse_all(
        DBConnection.execute(<<-SQL, *params.values
          SELECT
            *
          FROM
            #{self.table_name}
          WHERE
            #{where_string}
        SQL
        )
    )
  end

  def self.columns
    sql_result = DBConnection.get_first_row("SELECT * FROM #{table_name}")
    columns = []

    sql_result.keys.each do |key|
      key = key.to_sym
      columns << key
    end
      columns << :id unless columns.include?(:id)

    columns
  end

  def self.finalize!
    columns.each do |key|
      define_method(key) do
        attributes[key]
      end

      define_method("#{key}=") do |object|
        attributes[key] = object
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.downcase.pluralize
  end

  def self.all
      parse_all(DBConnection.execute("SELECT * FROM #{table_name}"))
  end

  def self.parse(result)
    self.new(result)
  end

  def self.parse_all(results)
    results.map { |result| parse(result) }
  end

  def self.find(id)

    query_result = DBConnection.get_first_row("SELECT * FROM #{table_name} WHERE id = #{id}")
    return nil if query_result.nil?
    parse(query_result)
  end

  def initialize(params = {})

    self.class.finalize!

    params.each do |column_name, value|
      raise "unknown attribute '#{column_name}'" unless self.class.columns.include?(column_name.to_sym)
      send("#{column_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert

    attributes[:id] ||= DBConnection.get_first_row("SELECT MAX(id) AS count FROM #{self.class.table_name};")["count"] + 1

    column_name_string = attributes.keys.inject("#{self.class.table_name} (") { |acc, col| acc + "#{col}," }
    column_name_string = column_name_string[0...-1] + ")"

    value_string = attribute_values.inject("(") {|acc, val| acc + "?,"}
    value_string = value_string[0...-1] + ")"


    database = DBConnection.execute(<<-SQL, *attribute_values
      INSERT INTO
        #{column_name_string}
      VALUES
        #{value_string}
    SQL
    )
  end

  def update
    update_string = attributes.keys.inject('') { |acc, key| acc + "#{key} = ?,"  }
    update_string = update_string[0...-1]

    database = DBConnection.execute(<<-SQL, *attribute_values
      UPDATE
        #{self.class.table_name}
      SET
        #{update_string}
      WHERE
        id = #{attributes[:id]}
    SQL
    )


  end



  def save
    if attributes[:id]
      update
    else
      insert
    end
  end
end
