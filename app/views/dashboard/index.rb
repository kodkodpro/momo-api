# typed: true
# frozen_string_literal: true

class Views::Dashboard::Index < Views::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :title, String
  end

  def view_template
    h1 { "Dashboard::Index #{title}" }
    p { "Find me in app/views/dashboard/index.rb" }
  end
end
