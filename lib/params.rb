require 'uri'
require 'byebug'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # You haven't done routing yet; but assume route params will be
  # passed in as a hash to `Params.new` as below:
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

  # this will be useful if we want to `puts params` in the server log
  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
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

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

end
