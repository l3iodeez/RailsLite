require 'uri'
require 'byebug'

class Params

  def initialize(req, route_params = {})

    @params = {}
    if req.query_string
      @params = parse_www_encoded_form(req.query_string)
    end
    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    end
    @params.merge!(route_params)
  end

  def [](key)
    @params[key.to_sym] || @params[key.to_s]
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  def parse_www_encoded_form(www_encoded_form)
    result = {}
    encoded_params = URI::decode_www_form(www_encoded_form)

      encoded_params.each do |duplet|

        keys = parse_key(duplet[0])
        result[keys[0]] ||= {}
        current_level = result
        result[keys[0]] = duplet[1] if keys.count == 1
        keys.each do |key|
          current_level[key] ||= {}
          if key == keys.last
            current_level[key] = duplet[1]
          else
          current_level = current_level[key]
          end
        end
      end
    result
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

end
