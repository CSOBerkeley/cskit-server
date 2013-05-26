# encoding: UTF-8

module CSKit
  module Api
    module V1

      class Base < Grape::API

        version 'v1', :using => :path
        # rescue_from :all

        mount CSKit::Api::V1::LessonEndpoints => "/"

      end
    end
  end
end
