require 'byebug'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

require_relative 'flash'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_built_response = false
    @params = Params.new(req, route_params)

    if req.request_method == "POST"
      raise "Invalid Authenticity Token" unless session["authenticity_token"] == params[:authenticity_token]
    end
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise "Double render/redirect" if @already_built_response

    @res["Location"] = url
    @res.status = 302
    @already_built_response = true
    flash.store_flash(@res)
    session.store_session(@res)

    nil
  end

  def render_content(content, content_type)
    raise "Double render or redirect" if @already_built_response
    @res.content_type = content_type
    @res.body = content
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)

    nil
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    path = "views/#{controller_name}/#{template_name}.html.erb"
    file = File.read(path)
    render_content(ERB.new(file).result(binding), "text/html")
  end


  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def form_authenticity_token
    @authenticity_token ||= SecureRandom::urlsafe_base64
    session[:authenticity_token] = @authenticity_token
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?

    nil
  end

end
