# typed: strict
# frozen_string_literal: true

class PublicController < ApplicationController
  skip_before_action :current_user
end
