require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "shows archive statistics dashboard" do
    get root_url

    assert_response :success
    assert_select "h1", text: "Statistik Arsip Magang"
    assert_select "[data-stat-card]", count: 6
    assert_select "[data-chart-card]", count: 4
    assert_select "progress[aria-label*='persen kuota diberikan']", count: 1
    assert_select "a[href=?]", vacancies_path
    assert_select "a[href=?]", organizers_path
  end

  test "shows statistics for selected period" do
    vacancies(:two).update!(published_at: Time.zone.local(2026, 9, 3, 12))

    get root_url, params: { period: "2026-07" }

    assert_response :success
    assert_select "p", text: /Juli 2026/
    assert_select "[data-stat-card]", text: /Total lowongan.*1/m
  end
end
