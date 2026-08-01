require "test_helper"

class OrganizersHelperTest < ActionView::TestCase
  test "translates organizer types" do
    assert_equal "Pemerintah", organizer_type_label("Government")
    assert_equal "Perusahaan", organizer_type_label("company")
    assert_equal "Penyelenggara", organizer_type_label(nil)
  end
end
