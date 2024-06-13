require "application_system_test_case"

class PropertyUtilitiesTest < ApplicationSystemTestCase
  setup do
    @property_utility = property_utilities(:one)
  end

  test "visiting the index" do
    visit property_utilities_url
    assert_selector "h1", text: "Property Utilities"
  end

  test "creating a Property utility" do
    visit property_utilities_url
    click_on "New Property Utility"

    fill_in "Frequency", with: @property_utility.frequency
    check "Included" if @property_utility.included
    fill_in "Landlord contribution", with: @property_utility.landlord_contribution
    fill_in "Property", with: @property_utility.property_id
    fill_in "Utility name", with: @property_utility.utility_name
    click_on "Create Property utility"

    assert_text "Property utility was successfully created"
    click_on "Back"
  end

  test "updating a Property utility" do
    visit property_utilities_url
    click_on "Edit", match: :first

    fill_in "Frequency", with: @property_utility.frequency
    check "Included" if @property_utility.included
    fill_in "Landlord contribution", with: @property_utility.landlord_contribution
    fill_in "Property", with: @property_utility.property_id
    fill_in "Utility name", with: @property_utility.utility_name
    click_on "Update Property utility"

    assert_text "Property utility was successfully updated"
    click_on "Back"
  end

  test "destroying a Property utility" do
    visit property_utilities_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Property utility was successfully destroyed"
  end
end
