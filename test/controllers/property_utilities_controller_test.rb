require 'test_helper'

class PropertyUtilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @property_utility = property_utilities(:one)
  end

  test "should get index" do
    get property_utilities_url
    assert_response :success
  end

  test "should get new" do
    get new_property_utility_url
    assert_response :success
  end

  test "should create property_utility" do
    assert_difference('PropertyUtility.count') do
      post property_utilities_url, params: { property_utility: { frequency: @property_utility.frequency, included: @property_utility.included, landlord_contribution: @property_utility.landlord_contribution, property_id: @property_utility.property_id, utility_name: @property_utility.utility_name } }
    end

    assert_redirected_to property_utility_url(PropertyUtility.last)
  end

  test "should show property_utility" do
    get property_utility_url(@property_utility)
    assert_response :success
  end

  test "should get edit" do
    get edit_property_utility_url(@property_utility)
    assert_response :success
  end

  test "should update property_utility" do
    patch property_utility_url(@property_utility), params: { property_utility: { frequency: @property_utility.frequency, included: @property_utility.included, landlord_contribution: @property_utility.landlord_contribution, property_id: @property_utility.property_id, utility_name: @property_utility.utility_name } }
    assert_redirected_to property_utility_url(@property_utility)
  end

  test "should destroy property_utility" do
    assert_difference('PropertyUtility.count', -1) do
      delete property_utility_url(@property_utility)
    end

    assert_redirected_to property_utilities_url
  end
end
