# typed: true
# frozen_string_literal: true

class Views::Dashboard::Analytics::AnalyzeEvent < Views::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :analyzed_event, Analytics::AnalyzedEvent
  end

  delegate :analyzed_event, to: :props

  def view_template
    div class: "container p-4 sm:py-20 sm:px-0" do
      Heading level: 1 do
        analyzed_event.event_name.const_name.dasherize.titleize
      end

      Text class: "mt-1" do
        "From #{analyzed_event.start_date.to_date.to_human} to #{analyzed_event.end_date.to_date.to_human}, grouped by #{analyzed_event.group_by.human_name}"
      end

      render_filters

      Card class_name: "mt-4" do
        raw line_chart analyzed_event.grouped_counts, xmin: analyzed_event.start_date, xmax: analyzed_event.end_date # rubocop:disable Rails/OutputSafety
      end

      pre class: "mt-8" do
        code do
          JSON.pretty_generate(analyzed_event.to_h)
        end
      end
    end
  end

  private

  def render_filters
    form(
      method: "get",
      action: dashboard_analytics_analyze_event_path,
      class: "mt-4 flex flex-wrap gap-3",
      data: { auto_submit: "" },
    ) do
      FilterSelect(
        name: "event_name",
        label: "Event",
        options: Analytics::EventName.values.map { |value| [value.serialize.to_s, value.const_name.dasherize.titleize] },
        selected: analyzed_event.event_name.serialize.to_s,
      )

      FilterSelect(
        name: "period",
        label: "Period",
        options: Analytics::Period.values.map { |value| [value.serialize.to_s, value.human_name] },
        selected: analyzed_event.period.serialize.to_s,
      )

      FilterSelect(
        name: "group_by",
        label: "Group by",
        options: analyzed_event.period.allowed_group_bys.map { |value| [value.serialize.to_s, value.human_name] },
        selected: analyzed_event.group_by.serialize.to_s,
      )
    end
  end
end
