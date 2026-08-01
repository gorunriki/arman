require "test_helper"

class OrganizersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get organizers_url

    assert_response :success
    assert_select "h1", text: "Daftar Penyelenggara Magang"
    assert_select "tbody tr", count: Organizer.count
    assert_select "tbody tr", text: /Organizer One/
  end

  test "searches organizers by name" do
    get organizers_url, params: { q: "One" }

    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody tr", text: /Organizer One/
  end

  test "filters organizers by city and type" do
    get organizers_url, params: {
      city_id: cities(:one).id,
      organizer_type: "Company"
    }

    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody tr", text: /Organizer One/
  end

  test "ignores an invalid city id" do
    get organizers_url, params: { city_id: "invalid" }

    assert_response :success
    assert_select "tbody tr", count: Organizer.count
  end
end
