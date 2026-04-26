# typed: true
# frozen_string_literal: true

require "tailwind_merge"

class RubyUI::Base < Phlex::HTML
  TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze unless defined?(TAILWIND_MERGER)

  attr_reader :attrs

  def initialize(**user_attrs)
    super()

    @attrs = mix(default_attrs, user_attrs)
    @attrs[:class] = TAILWIND_MERGER.merge(@attrs[:class]) if @attrs[:class]
  end

  private

  def default_attrs
    {}
  end
end
