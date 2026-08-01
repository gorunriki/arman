require "test_helper"

class VacanciesControllerTest < ActionDispatch::IntegrationTest
  test "shows active vacancies" do
    get vacancies_url

    assert_response :success
    assert_select "h1", text: "Temukan Lowongan Magang"
    assert_select "article", count: Vacancy.active.count
  end

  test "searches vacancies by position" do
    get vacancies_url, params: { q: "Software" }

    assert_response :success
    assert_select "article", count: 1
    assert_select "article", text: /Software Engineer/
  end

  test "filters vacancies by education level" do
    get vacancies_url, params: { education_level: "diploma" }

    assert_response :success
    assert_select "article", count: 1
    assert_select "article", text: /Nutrition Assistant/
  end

  test "ignores invalid filter values" do
    get vacancies_url, params: { city_id: "invalid", education_level: "invalid" }

    assert_response :success
    assert_select "article", count: Vacancy.active.count
  end
end
