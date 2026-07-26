require "test_helper"

class OrganizersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get organizers_index_url
    assert_response :success
  end
end
