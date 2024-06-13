require "application_system_test_case"

class SystemContentDataCategoriesTest < ApplicationSystemTestCase
  setup do
    @system_content_data_category = system_content_data_categories(:one)
  end

  test "visiting the index" do
    visit system_content_data_categories_url
    assert_selector "h1", text: "System Content Data Categories"
  end

  test "creating a System content data category" do
    visit system_content_data_categories_url
    click_on "New System Content Data Category"

    fill_in "Category", with: @system_content_data_category.category
    fill_in "Title", with: @system_content_data_category.title
    click_on "Create System content data category"

    assert_text "System content data category was successfully created"
    click_on "Back"
  end

  test "updating a System content data category" do
    visit system_content_data_categories_url
    click_on "Edit", match: :first

    fill_in "Category", with: @system_content_data_category.category
    fill_in "Title", with: @system_content_data_category.title
    click_on "Update System content data category"

    assert_text "System content data category was successfully updated"
    click_on "Back"
  end

  test "destroying a System content data category" do
    visit system_content_data_categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "System content data category was successfully destroyed"
  end
end
