require 'test_helper'

class TenanciesControllerTest < ActionDispatch::IntegrationTest
  context 'closed_dashboard' do
    setup do
      @landlord = Landlord.create!(contact_name: 'LL', email: 'landlord@test.com', partnership_format: 5)
      @property = Property.create!(landlord: @landlord, street: 'Street A', postcode: 'ABC 123')
      @room = Room.create!(property: @property, number: 1)
      @tenancy = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('27/09/2021'),
        tenancy_end: Date.parse('27/09/2022')
      )
    end

    should 'not require authentication' do
      get closed_dashboard_path(@tenancy.uri_string)
      assert_response :ok
      assert_template layout: :tenancy_dashboard
    end
  end

  context 'redirect_away_if_booking_race_lost' do
    setup do
      @landlord = Landlord.create!(contact_name: 'LL', email: 'landlord@test.com', partnership_format: 5)
      @property = Property.create!(landlord: @landlord, street: 'Street A', postcode: 'ABC 123')
      @room = Room.create!(property: @property, number: 1)
      @tenancy = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('27/09/2021'),
        tenancy_end: Date.parse('27/09/2022')
      )
    end

    should 'not redirect away if tenant is only tenancy' do
      get tenancy_dashboard_path(@tenancy.uri_string)
      assert_response :ok
    end

    should 'not redirect away if no other tenancy has final_submission set' do
      Tenancy.create!(
        email: 'anotherguy@test.com',
        first_name: 'another',
        surname: 'guy',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('27/09/2021'),
        tenancy_end: Date.parse('27/09/2022'),
        final_submission: false
      )

      get tenancy_dashboard_path(@tenancy.uri_string)
      assert_response :ok
    end

    should 'not redirect away if tenancy with final_submission set has an end date before the start date' do
      Tenancy.create!(
        email: 'anotherguy@test.com',
        first_name: 'another',
        surname: 'guy',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('26/05/2021'),
        tenancy_end: Date.parse('26/09/2021'),
        final_submission: true
      )

      get tenancy_dashboard_path(@tenancy.uri_string)
      assert_response :ok
    end

    should 'not redirect away if tenancy with final_submission set is self' do
      @tenancy.update!(final_submission: true)
      get tenancy_dashboard_path(@tenancy.uri_string)
      assert_response :ok
    end

    should 'redirect away if tenancy with final_submission set has an end date after the start date' do
      Tenancy.create!(
        email: 'anotherguy@test.com',
        first_name: 'another',
        surname: 'guy',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('27/09/2021'),
        tenancy_end: Date.parse('27/09/2022'),
        final_submission: true
      )

      get tenancy_dashboard_path(@tenancy.uri_string)
      assert_redirected_to closed_dashboard_path(@tenancy.uri_string)
    end
  end
end
