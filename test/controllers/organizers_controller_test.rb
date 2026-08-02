require "test_helper"

class OrganizersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get organizers_url

    assert_response :success
    assert_select "h1", text: "Daftar Penyelenggara Magang"
    assert_select "[data-organizer-row]", count: Organizer.count
    assert_select "[data-organizer-row]", text: /Organizer One/
    assert_select "a[href=?]", organizer_path(organizers(:one)) do
      assert_select "[data-organizer-row]", count: 1
    end
  end

  test "searches organizers by name" do
    get organizers_url, params: { q: "One" }

    assert_response :success
    assert_select "[data-organizer-row]", count: 1
    assert_select "[data-organizer-row]", text: /Organizer One/
  end

  test "filters organizers by city and type" do
    get organizers_url, params: {
      city_id: cities(:one).id,
      organizer_type: "Company"
    }

    assert_response :success
    assert_select "[data-organizer-row]", count: 1
    assert_select "[data-organizer-row]", text: /Organizer One/
  end

  test "ignores an invalid city id" do
    get organizers_url, params: { city_id: "invalid" }

    assert_response :success
    assert_select "[data-organizer-row]", count: Organizer.count
  end

  test "shows an organizer and its vacancies" do
    organizer = organizers(:one)

    get organizer_url(organizer)

    assert_response :success
    assert_select "h1", text: organizer.name
    assert_select "[data-vacancy-card]", count: organizer.vacancies.count
  end

  test "returns not found for an unknown organizer" do
    get organizer_url("00000000-0000-4000-8000-000000000000")

    assert_response :not_found
  end
end
