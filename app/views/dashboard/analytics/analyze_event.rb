# typed: true
# frozen_string_literal: true

class Views::Dashboard::Analytics::AnalyzeEvent < Views::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :analyzed_event, Analytics::AnalyzedEvent
  end

  def view_template
    div class: "container p-4 sm:py-20 sm:px-0" do
      Heading level: 1 do
        analyzed_event.event_name.const_name.dasherize.titleize
      end

      Text class: "mt-1" do
        "From #{analyzed_event.start_date.to_human} to #{analyzed_event.end_date.to_human}, grouped by #{analyzed_event.group_by.const_name.humanize}"
      end

      Card className: "mt-4" do
        raw line_chart analyzed_event.grouped_counts, xmin: analyzed_event.start_date, xmax: analyzed_event.end_date
      end

      pre class: "mt-8" do
        code do
          JSON.pretty_generate(analyzed_event.to_h)
        end
      end
    end
  end
end
