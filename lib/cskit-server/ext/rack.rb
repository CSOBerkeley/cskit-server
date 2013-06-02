# encoding: UTF-8

module Rack
  module Utils

    # Modify rack so it doesn't split URL params by semicolons.
    # Used suppress_warnings because we're doing a constant redefinition.
    # See: https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L66
    suppress_warnings do
      DEFAULT_SEP = /[&] */n
    end

  end
end