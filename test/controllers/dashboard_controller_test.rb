# typed: true
# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_url, headers: {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
        Env.dashboard_username,
        Env.dashboard_password,
      ),
    }

    assert_response :success
  end

  test "should require authentication" do
    get dashboard_url

    assert_response :unauthorized
  end
end
