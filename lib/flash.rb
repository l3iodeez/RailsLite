require 'json'
require 'webrick'
require 'byebug'

class Flash
  def initialize(req)
    cookie = req.cookies.find { |cookie| cookie.name == "_rails_lite_app_flash" }
    @flash_now = cookie.nil? ? {} : JSON.parse(cookie.value)
    @flash = {}
  end

  def [](key)
    [
      @flash[key.to_sym],
      @flash[key.to_s],
      @flash_now[key.to_s],
      @flash_now[key.to_sym]
    ].flatten.compact.first
  end

  def []=(flash_type, value)
    @flash[flash_type] = value
  end

  def now
    @flash_now
  end

  def store_flash(res)
    flash_cookie = WEBrick::Cookie.new(
      "_rails_lite_app_flash",
       @flash.to_json
    )
    flash_cookie.path = "/"
    res.cookies << flash_cookie
  end

end
