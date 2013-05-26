# encoding: UTF-8

require 'grape'

require 'cskit'
require 'cskit/bible/kjv'
require 'cskit/science_health'
require 'cskit-server/api/v1'

module CSKit
  module Api
    class Base < Grape::API

      mount CSKit::Api::V1::Base => "/v1"

    end
  end
end
