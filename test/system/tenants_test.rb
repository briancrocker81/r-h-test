require "application_system_test_case"

class TenantsTest < ApplicationSystemTestCase
  setup do
    @tenant = tenants(:one)
  end

  test "visiting the index" do
    visit tenants_url
    assert_selector "h1", text: "Tenants"
  end

  test "creating a Tenant" do
    visit tenants_url
    click_on "New Tenant"

    fill_in "Course", with: @tenant.course
    fill_in "Dob", with: @tenant.dob
    fill_in "Email", with: @tenant.email
    fill_in "First name", with: @tenant.first_name
    fill_in "Guarantor address", with: @tenant.guarantor_address
    fill_in "Guarantor email", with: @tenant.guarantor_email
    fill_in "Guarantor mobile", with: @tenant.guarantor_mobile
    fill_in "Guarantor name", with: @tenant.guarantor_name
    fill_in "Guarantor post code", with: @tenant.guarantor_post_code
    fill_in "Guarantor relationship", with: @tenant.guarantor_relationship
    fill_in "Mobile number", with: @tenant.mobile_number
    fill_in "Nationality", with: @tenant.nationality
    fill_in "Student id number", with: @tenant.student_id_number
    fill_in "Studying at", with: @tenant.studying_at
    fill_in "Surname", with: @tenant.surname
    click_on "Create Tenant"

    assert_text "Tenant was successfully created"
    click_on "Back"
  end

  test "updating a Tenant" do
    visit tenants_url
    click_on "Edit", match: :first

    fill_in "Course", with: @tenant.course
    fill_in "Dob", with: @tenant.dob
    fill_in "Email", with: @tenant.email
    fill_in "First name", with: @tenant.first_name
    fill_in "Guarantor address", with: @tenant.guarantor_address
    fill_in "Guarantor email", with: @tenant.guarantor_email
    fill_in "Guarantor mobile", with: @tenant.guarantor_mobile
    fill_in "Guarantor name", with: @tenant.guarantor_name
    fill_in "Guarantor post code", with: @tenant.guarantor_post_code
    fill_in "Guarantor relationship", with: @tenant.guarantor_relationship
    fill_in "Mobile number", with: @tenant.mobile_number
    fill_in "Nationality", with: @tenant.nationality
    fill_in "Student id number", with: @tenant.student_id_number
    fill_in "Studying at", with: @tenant.studying_at
    fill_in "Surname", with: @tenant.surname
    click_on "Update Tenant"

    assert_text "Tenant was successfully updated"
    click_on "Back"
  end

  test "destroying a Tenant" do
    visit tenants_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tenant was successfully destroyed"
  end
end
