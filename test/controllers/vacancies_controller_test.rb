require "test_helper"

class VacanciesControllerTest < ActionDispatch::IntegrationTest
  test "shows archived vacancies" do
    get vacancies_url

    assert_response :success
    assert_select "h1", text: "Arsip Lowongan Magang"
    assert_select "article", count: Vacancy.count
    assert_select "a[href=?]", vacancy_path(vacancies(:one)) do
      assert_select "article", count: 1
    end
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

  test "filters vacancies by organizer type" do
    get vacancies_url, params: { organizer_type: "government" }

    assert_response :success
    assert_select "article", count: 1
    assert_select "article", text: /Nutrition Assistant/
  end

  test "filters vacancies by application count" do
    vacancies(:two).update!(total_applications: 25)

    get vacancies_url, params: { application_range: "11_50" }

    assert_response :success
    assert_select "article", count: 1
    assert_select "article", text: /Nutrition Assistant/
  end

  test "ignores invalid filter values" do
    get vacancies_url, params: { city_id: "invalid", education_level: "invalid", application_range: "invalid" }

    assert_response :success
    assert_select "article", count: Vacancy.count
  end

  test "shows an archived vacancy" do
    vacancy = vacancies(:one)

    get vacancy_url(vacancy)

    assert_response :success
    assert_select "h1", text: vacancy.position_name
    assert_select "h2", text: "Deskripsi tugas"
    assert_select "a[href=?]", organizer_path(vacancy.organizer) do
      assert_select "h2", text: "Informasi penyelenggara"
    end
  end

  test "returns not found for an unknown vacancy" do
    get vacancy_url("00000000-0000-4000-8000-000000000000")

    assert_response :not_found
  end
end
