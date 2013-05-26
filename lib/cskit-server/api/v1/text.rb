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

          optional :text_format, {
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

          def formatter_for(volume, type)
            type_str = type.to_s.split("_").map(&:capitalize).join
            namespace_str = volume.config[:type].to_s.split("_").map(&:capitalize).join
            sym = :"#{namespace_str}#{type_str}Formatter"
            @formatters ||= {}
            @formatters[sym] ||= CSKit::Formatters.const_get(namespace_str.to_sym).const_get(sym).new
          end
        end

        get :text do
          volume_pairs(params[:citations]).map do |volume_name, citation_text|
            volume = CSKit.get_volume(volume_name)
            citation = volume.parse_citation(citation_text)
            readings = volume.readings_for(citation)
            formatter = formatter_for(volume, params[:text_format] || "plain_text")

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