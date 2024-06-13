require "application_system_test_case"

class TenanciesTest < ApplicationSystemTestCase
  setup do
    @tenancy = tenancies(:one)
  end

  test "visiting the index" do
    visit tenancies_url
    assert_selector "h1", text: "Tenancies"
  end

  test "creating a Tenancy" do
    visit tenancies_url
    click_on "New Tenancy"

    check "Accept agreement" if @tenancy.accept_agreement
    check "Criminal record" if @tenancy.criminal_record
    fill_in "Dob", with: @tenancy.dob
    fill_in "Email", with: @tenancy.email
    fill_in "First name", with: @tenancy.first_name
    fill_in "Mobile", with: @tenancy.mobile
    fill_in "Nationality", with: @tenancy.nationality
    fill_in "Property", with: @tenancy.property_id
    fill_in "Rate", with: @tenancy.rate
    check "Status" if @tenancy.status
    fill_in "Surname", with: @tenancy.surname
    fill_in "Tenancy end", with: @tenancy.tenancy_end
    check "Tenancy rate" if @tenancy.tenancy_rate
    fill_in "Tenancy start", with: @tenancy.tenancy_start
    check "Tenant type" if @tenancy.tenant_type
    fill_in "Year", with: @tenancy.year
    click_on "Create Tenancy"

    assert_text "Tenancy was successfully created"
    click_on "Back"
  end

  test "updating a Tenancy" do
    visit tenancies_url
    click_on "Edit", match: :first

    check "Accept agreement" if @tenancy.accept_agreement
    check "Criminal record" if @tenancy.criminal_record
    fill_in "Dob", with: @tenancy.dob
    fill_in "Email", with: @tenancy.email
    fill_in "First name", with: @tenancy.first_name
    fill_in "Mobile", with: @tenancy.mobile
    fill_in "Nationality", with: @tenancy.nationality
    fill_in "Property", with: @tenancy.property_id
    fill_in "Rate", with: @tenancy.rate
    check "Status" if @tenancy.status
    fill_in "Surname", with: @tenancy.surname
    fill_in "Tenancy end", with: @tenancy.tenancy_end
    check "Tenancy rate" if @tenancy.tenancy_rate
    fill_in "Tenancy start", with: @tenancy.tenancy_start
    check "Tenant type" if @tenancy.tenant_type
    fill_in "Year", with: @tenancy.year
    click_on "Update Tenancy"

    assert_text "Tenancy was successfully updated"
    click_on "Back"
  end

  test "destroying a Tenancy" do
    visit tenancies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tenancy was successfully destroyed"
  end
end
