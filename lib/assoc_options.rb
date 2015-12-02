class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options[:primary_key] ||= :id
    options[:class_name] ||= name.to_s.camelize.singularize
    options[:foreign_key] ||= "#{name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options[:primary_key] ||= :id
    options[:class_name] ||= name.to_s.camelize.singularize
    options[:foreign_key] ||= "#{self_class_name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end
