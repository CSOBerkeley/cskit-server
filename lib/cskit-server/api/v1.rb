# encoding: UTF-8



module CSKit
  module Api
    module V1
      autoload :Base,            "cskit-server/api/v1/base"
      autoload :LessonEndpoints, "cskit-server/api/v1/lesson"
      autoload :TextEndpoints,   "cskit-server/api/v1/text"
      autoload :JsonValidator,   "cskit-server/api/v1/json_validator"
    end
  end
end