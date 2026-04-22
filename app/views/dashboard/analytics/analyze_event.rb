# typed: true
# frozen_string_literal: true

class Views::Dashboard::Analytics::AnalyzeEvent < Views::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :data, Analytics::AnalyzeEvent::Data
  end

  def view_template
    div class: "container" do
      h1 { "Dashboard::Analytics::AnalyzeEvent" }
      p { "Find me in app/views/dashboard/analytics/analyze_event.rb" }

      Button { "Click Me" }

      Card { "Another Example" }

      pre do
        code do
          JSON.pretty_generate(data.to_h)
        end
      end
    end
  end
end
