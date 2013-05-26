# encoding: UTF-8

require 'rack/contrib'

module CSKit
  module Api
    module V1

      class Base < Grape::API

        use Rack::JSONP

        version 'v1', :using => :path
        # rescue_from :all
        default_format :json

        mount CSKit::Api::V1::LessonEndpoints => "/"

      end
    end
  end
end
