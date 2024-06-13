require "application_system_test_case"

class CompaniesTest < ApplicationSystemTestCase
  setup do
    @company = companies(:one)
  end

  test "visiting the index" do
    visit companies_url
    assert_selector "h1", text: "Companies"
  end

  test "creating a Company" do
    visit companies_url
    click_on "New Company"

    fill_in "Address", with: @company.address
    fill_in "Bank account name", with: @company.bank_account_name
    fill_in "Bank account number", with: @company.bank_account_number
    fill_in "Bank address", with: @company.bank_address
    fill_in "Bank bic", with: @company.bank_bic
    fill_in "Bank iban", with: @company.bank_iban
    fill_in "Bank name", with: @company.bank_name
    fill_in "Bank sort code", with: @company.bank_sort_code
    fill_in "Main contact", with: @company.main_contact
    fill_in "Main email", with: @company.main_email
    fill_in "Name", with: @company.name
    fill_in "Phone number", with: @company.phone_number
    fill_in "Registration number", with: @company.registration_number
    fill_in "Vat number", with: @company.vat_number
    click_on "Create Company"

    assert_text "Company was successfully created"
    click_on "Back"
  end

  test "updating a Company" do
    visit companies_url
    click_on "Edit", match: :first

    fill_in "Address", with: @company.address
    fill_in "Bank account name", with: @company.bank_account_name
    fill_in "Bank account number", with: @company.bank_account_number
    fill_in "Bank address", with: @company.bank_address
    fill_in "Bank bic", with: @company.bank_bic
    fill_in "Bank iban", with: @company.bank_iban
    fill_in "Bank name", with: @company.bank_name
    fill_in "Bank sort code", with: @company.bank_sort_code
    fill_in "Main contact", with: @company.main_contact
    fill_in "Main email", with: @company.main_email
    fill_in "Name", with: @company.name
    fill_in "Phone number", with: @company.phone_number
    fill_in "Registration number", with: @company.registration_number
    fill_in "Vat number", with: @company.vat_number
    click_on "Update Company"

    assert_text "Company was successfully updated"
    click_on "Back"
  end

  test "destroying a Company" do
    visit companies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Company was successfully destroyed"
  end
end
