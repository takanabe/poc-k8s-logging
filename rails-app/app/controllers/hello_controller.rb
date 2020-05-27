# frozen_string_literal: true

require 'json'

class HelloController < ApplicationController
  def hello
    render json: {
      log: 'hello'
    }
  end

  def hi
    render json: {
      log: 'hi'
    }
  end

  def error
    raise "Error in HelloController!!!"
  end
end
