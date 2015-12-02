require 'active_support'
require 'active_support/core_ext'
require 'webrick'
require_relative '../lib/controller_base'
require_relative '../lib/SQLObject'
require_relative 'modles'




class HumansController < ControllerBase
end

class CatsController < ControllerBase
  def create
    @cat = Cat.new(params["cat"])
    if @cat.save
      flash[:notice] = ["Cat saved"]
      redirect_to("/cats")
    else
      flash.now[:notice] = ["Cat is invalid"]
      render :new
    end
  end

  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end
end
