# encoding: UTF-8

include CSKit::Lesson
include CSKit::Formatters::ScienceHealth
include CSKit::Formatters::Bible

module CSKit
  module Api
    module V1
      class LessonEndpoints < Grape::API

        class LessonJsonValidator < JsonValidator
          def validate_param!(attr_name, params)
            lesson_data = parse_json(params[attr_name], "#{attr_name} is not valid JSON.")
            validate_lesson(lesson_data, attr_name)
          end

          protected

          def validate_lesson(lesson_data, attr_name)
            expect_type(lesson_data, Array, "#{attr_name}: expected an array of sections.")
            lesson_data.each { |section_data| validate_section(section_data, attr_name) }
          end

          def validate_section(section_data, attr_name)
            expect_type(section_data, Hash, "#{attr_name}/section: Expected a hash, got a #{section_data.class.to_s}.")
            expect_hash_to_have(section_data, "section", :anything, "#{attr_name}/section: Must have a section name.")
            expect_hash_to_have(section_data, "readings", :anything, "#{attr_name}/section: Must contain an array of readings.")
            validate_readings(section_data["readings"], attr_name)
          end

          def validate_readings(readings_data, attr_name)
            expect_type(readings_data, Hash, "#{attr_name}/section/readings: Expected a hash, got a #{readings_data.class.to_s}.")
            readings_data.each_pair do |volume, citation_list|
              validate_volume(volume, attr_name)
              validate_citation_list(citation_list, attr_name)
            end
          end

          def validate_citation_list(citation_list, attr_name)
            expect_type(citation_list, Array, "#{attr_name}/section/readings/citation_list: Expected an array, got a #{citation_list.class.to_s}.")
            citation_list.each { |citation| validate_citation(citation, attr_name) }
          end

          def validate_volume(volume, attr_name)
            expect_type(volume, String, "#{attr_name}/section/readings/citation_list/volume: Expected a string, got a #{volume.class.to_s}.")
          end

          def validate_citation(citation, attr_name)
            expect_type(citation, String, "#{attr_name}/section/readings/citation_list/citation: Expected a string, got a #{citation.class.to_s}.")
          end
        end

        class FormatterListValidator < Grape::Validations::Validator
          def validate_param!(attr_name, params)
            formatter_hash = parse_json(params[attr_name], "#{attr_name} is not valid JSON.")
            expect_type(formatter_hash, Hash, "#{attr_name}: Expected a hash, got a #{formatter_hash.class.to_s}")
            formatter_hash.each_pair { |volume, formatter| validate_formatter(formatter, attr_name) }
          end

          protected

          def validate_formatter(formatter, attr_name)
            # eventually check if the formatter exists and is loaded
          end
        end

        desc "Retrieves text for a lesson, i.e. a list of grouped citations per volume."

        params do
          requires :payload, {
            :type => String,
            :lesson_json => true
          }

          optional :formatters, {
            :type => String,
            :formatter_list => true
          }
        end
        
        get "lesson/text" do
          result = {}
          lesson = CSKit::Lesson::Lesson.from_json(params[:payload])
          formatters = {  # just use the defaults for now
            :science_health => ScienceHealthPlainTextFormatter.new,
            :bible          => BiblePlainTextFormatter.new
          }

          lesson.each_formatted_section(formatters) do |section, text_by_volume|
            result[section.name] = text_by_volume
          end

          result
        end

        get "lesson/dummy" do
          ["hello, world"]
        end
      end
    end
  end
end