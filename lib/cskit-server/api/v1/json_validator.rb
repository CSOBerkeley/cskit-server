# encoding: UTF-8

module CSKit
  module Api
    module V1
      class JsonValidator < Grape::Validations::Validator

        def parse_json(text, error_message)
          if data = JSON.parse(text) rescue nil
            data
          else
            throw :error, :status => 400, :message => error_message
          end
        end

        def expect_type(obj, type, error_message)
          unless obj.is_a?(type)
            throw :error, :status => 400, :message => error_message
          end
        end

        def expect_hash_to_have(hash, key, val, error_message)
          unless val == :anything ? hash.include?(key) : hash[key] == val
            throw :error, :status => 400, :message => error_message
          end
        end

      end
    end
  end
end