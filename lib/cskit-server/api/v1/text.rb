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

          optional :annotator, {
            :type => String
          }

          optional :annotation_format, {
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

          # This is horrible. It would be much better if gems could register their own formatters.
          # We could then provide access to them via a get_formatter method in CSKit.
          # That's how annotators do it, anyway.
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

            text = if params[:annotator]
              annotator = CSKit.get_annotator(params[:annotator].to_sym)
              annotation_formatter = annotator.get_formatter(params[:annotation_format].to_sym).new

              annotated_readings = readings.map do |reading|
                annotator.annotate(reading, volume)
              end

              formatter.format_annotated_readings(
                annotated_readings,
                annotation_formatter
              )
            else
              formatter.format_readings(readings)
            end

            header 'Content-Type', 'application/json; charset=utf-8'

            {
              volume: volume.config[:id],
              citation: citation,
              text: text
            }
          end
        end

      end
    end
  end
end
