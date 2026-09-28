require "test_helper"

class VacanciesControllerTest < ActionDispatch::IntegrationTest
  test "shows archived vacancies" do
    get vacancies_url

    assert_response :success
    assert_select "h1", text: "Arsip Lowongan Magang"
    assert_select "article", count: Vacancy.count
    assert_select "form span", text: "Jenis penyelenggara"
    assert_select "a", text: "Jelajahi lowongan", count: 0
    assert_select "time", text: /Dipublikasikan/, minimum: 1
    assert_select "footer", text: /Menampilkan 1–#{Vacancy.count} dari #{Vacancy.count} lowongan/
    assert_select "a[href=?]", vacancy_path(vacancies(:one)) do
      assert_select "article", count: 1
    end
  end

  test "searches vacancies by position" do
    get vacancies_url, params: { q: "Software" }

    assert_response :success
    assert_select "article", count: 1
    assert_select "article", text: /Software Engineer/
    assert_select "[aria-label='Filter aktif']", text: /Pencarian: Software/
    assert_select "a[data-turbo-frame='_top']", text: "Reset semua", count: 1
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
    assert_select "h2", text: "Informasi penyelenggara"
    assert_select "a[href=?][aria-label=?]",
                  organizer_path(vacancy.organizer),
                  "Lihat #{vacancy.organizer.name} dan arsip lowongannya"
    assert_select "p", text: "Kuota diberikan"
    assert_select "a[href^='https://www.google.com/maps/search/']", text: /Buka lokasi di Google Maps/
  end

  test "returns not found for an unknown vacancy" do
    get vacancy_url("00000000-0000-4000-8000-000000000000")

    assert_response :not_found
  end

  test "switches vacancies by publication period" do
    september = vacancies(:one).dup
    september.id = SecureRandom.uuid
    september.position_name = "September Internship"
    september.published_at = Time.zone.local(2026, 9, 3, 12)
    september.save!

    get vacancies_url, params: { period: "2026-07" }

    assert_response :success
    assert_select "article", text: /Software Engineer/
    assert_select "article", text: /September Internship/, count: 0
    assert_select "select[aria-label='Pilih periode arsip'] option[selected]", text: "Juli 2026"

    get vacancies_url, params: { period: "2026-09" }

    assert_response :success
    assert_select "article", text: /September Internship/
    assert_select "article", text: /Software Engineer/, count: 0
    assert_select "[aria-label='Keterangan kelengkapan arsip']", text: /tidak lengkap.*Maganghub direset/mi
  end

  test "defaults to the latest publication period" do
    september = vacancies(:one).dup
    september.id = SecureRandom.uuid
    september.position_name = "Latest Internship"
    september.published_at = Time.zone.local(2026, 9, 3, 12)
    september.save!

    get vacancies_url

    assert_response :success
    assert_select "article", text: /Latest Internship/
    assert_select "article", text: /Software Engineer/, count: 0
  end
end
