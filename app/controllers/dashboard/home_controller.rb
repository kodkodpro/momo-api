# typed: true
# frozen_string_literal: true

class Dashboard::HomeController < Dashboard::ApplicationController
  def index
    render Views::Dashboard::Index.new(title: "Dashboard")
  end
end
