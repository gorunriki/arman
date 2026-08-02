require "test_helper"

class VacanciesHelperTest < ActionView::TestCase
  test "translates education levels" do
    assert_equal "Sarjana", education_level_label("bachelor")
    assert_equal "Diploma", education_level_label("diploma")
    assert_equal "Profesi", education_level_label("profession")
  end

  test "translates days" do
    assert_equal "Senin", day_label("monday")
    assert_equal "Minggu", day_label("sunday")
  end
end
