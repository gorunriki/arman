require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "shows archive statistics dashboard" do
    get root_url

    assert_response :success
    assert_select "h1", text: "Statistik Arsip Magang"
    assert_select "[data-stat-card]", count: 6
    assert_select "[data-chart-card]", count: 4
    assert_select "a[href=?]", vacancies_path
    assert_select "a[href=?]", organizers_path
  end
end
