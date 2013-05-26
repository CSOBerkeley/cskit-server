# encoding: UTF-8

include CSKit::Formatters::ScienceHealth
include CSKit::Formatters::Bible

module CSKit
  module Api
    module V1
      class TextEndpoints < Grape::API

        desc "Retrieves text for a list of citations."

        params do
          requires :citations, {
            :type => String
          }
        end

        helpers do
          def volume_pairs(citations)
            Enumerator.new do |enum|
              citations.split("|").each do |citation|
                space = citation.index(" ")
                volume = citation[0..space].strip.to_sym
                citation = citation[space..-1].strip
                enum.yield(volume, citation)
              end
            end
          end
        end

        get :text do
          formatters = {  # just use the defaults for now
            :science_health => ScienceHealthPlainTextFormatter.new,
            :bible          => BiblePlainTextFormatter.new
          }

          volume_pairs(params[:citations]).map do |volume_name, citation_text|
            volume = CSKit.get_volume(volume_name)
            citation = volume.parse_citation(citation_text)
            readings = volume.readings_for(citation)
            formatter = formatters[volume.config[:type]]

            { :volume => volume.config[:id],
              :citation => citation,
              :text => formatter.format_readings(readings)
            }
          end
        end

      end
    end
  end
end