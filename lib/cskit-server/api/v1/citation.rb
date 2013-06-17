# encoding: UTF-8

require 'pry-nav'

module CSKit
  module Api
    module V1
      class CitationEndpoints < Grape::API

        params do

          requires :volume, {
            :type => String,
            :desc => "The name of the textual volume to parse the citation for, eg. bible_kjv or science_health."
          }

          requires :citation, {
            :type => String,
            :desc => "The citation to parse."
          }

        end

        desc "Parses the given citation text and returns a machine-readable json object."

        get :parse_citation do
          if volume = CSKit.get_volume(params[:volume].to_sym)
            begin
              citation = volume.parse_citation(params[:citation])
              citation.to_hash
            rescue NoMethodError
              error!("Invalid citation '#{params[:citation]}' for volume '#{params[:volume]}'.")
            end
          else
            error!("Couldn't find the volume named '#{params[:volume]}'")
          end
        end

      end
    end
  end
end