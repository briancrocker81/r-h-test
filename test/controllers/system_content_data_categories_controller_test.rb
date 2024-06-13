require 'test_helper'

class SystemContentDataCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @system_content_data_category = system_content_data_categories(:one)
  end

  test "should get index" do
    get system_content_data_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_system_content_data_category_url
    assert_response :success
  end

  test "should create system_content_data_category" do
    assert_difference('SystemContentDataCategory.count') do
      post system_content_data_categories_url, params: { system_content_data_category: { category: @system_content_data_category.category, title: @system_content_data_category.title } }
    end

    assert_redirected_to system_content_data_category_url(SystemContentDataCategory.last)
  end

  test "should show system_content_data_category" do
    get system_content_data_category_url(@system_content_data_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_system_content_data_category_url(@system_content_data_category)
    assert_response :success
  end

  test "should update system_content_data_category" do
    patch system_content_data_category_url(@system_content_data_category), params: { system_content_data_category: { category: @system_content_data_category.category, title: @system_content_data_category.title } }
    assert_redirected_to system_content_data_category_url(@system_content_data_category)
  end

  test "should destroy system_content_data_category" do
    assert_difference('SystemContentDataCategory.count', -1) do
      delete system_content_data_category_url(@system_content_data_category)
    end

    assert_redirected_to system_content_data_categories_url
  end
end
