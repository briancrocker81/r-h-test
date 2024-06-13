require 'test_helper'

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:one)
  end

  test "should get index" do
    get companies_url
    assert_response :success
  end

  test "should get new" do
    get new_company_url
    assert_response :success
  end

  test "should create company" do
    assert_difference('Company.count') do
      post companies_url, params: { company: { address: @company.address, bank_account_name: @company.bank_account_name, bank_account_number: @company.bank_account_number, bank_address: @company.bank_address, bank_bic: @company.bank_bic, bank_iban: @company.bank_iban, bank_name: @company.bank_name, bank_sort_code: @company.bank_sort_code, main_contact: @company.main_contact, main_email: @company.main_email, name: @company.name, phone_number: @company.phone_number, registration_number: @company.registration_number, vat_number: @company.vat_number } }
    end

    assert_redirected_to company_url(Company.last)
  end

  test "should show company" do
    get company_url(@company)
    assert_response :success
  end

  test "should get edit" do
    get edit_company_url(@company)
    assert_response :success
  end

  test "should update company" do
    patch company_url(@company), params: { company: { address: @company.address, bank_account_name: @company.bank_account_name, bank_account_number: @company.bank_account_number, bank_address: @company.bank_address, bank_bic: @company.bank_bic, bank_iban: @company.bank_iban, bank_name: @company.bank_name, bank_sort_code: @company.bank_sort_code, main_contact: @company.main_contact, main_email: @company.main_email, name: @company.name, phone_number: @company.phone_number, registration_number: @company.registration_number, vat_number: @company.vat_number } }
    assert_redirected_to company_url(@company)
  end

  test "should destroy company" do
    assert_difference('Company.count', -1) do
      delete company_url(@company)
    end

    assert_redirected_to companies_url
  end
end
