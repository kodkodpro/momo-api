# typed: true
# frozen_string_literal: true

class Views::Base < Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  # Includes
  include Chartkick::Helper

  # Helpers
  # register_output_helper :line_chart

  # More caching options at https://www.phlex.fun/components/caching
  def cache_store = Rails.cache
end
