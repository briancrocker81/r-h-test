require 'test_helper'

class TenancyTest < ActiveSupport::TestCase
  context '.in_arrears' do
    setup do
      setup_for_creating_tenancies
      @tenancy = Tenancy.create!(
        email: 'test@test.com',
        booking_status: 2,
        first_name: 'test',
        surname: 'test',
        room: @room,
        deposit_term: 'full',
        year: '21/22',
        tenancy_start: Date.parse('27/09/2021'),
        payment_amount: 1000
      )
      @tenancy.payment_edit = true
      @tenancy.create_payment_items
    end

    should 'not implode with blank in arrears payment item' do
      tpi = @tenancy.tenancy_payment_items.last
      tpi.update!(arrears: '')
      Tenancy.in_arrears.inspect
    end
  end

  context '.destroy_failed_to_book_tenancies_older_than' do
    setup do
      setup_for_creating_tenancies
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

    should 'destroy tenancies with failed_at older than the time given' do
      older_failed_at = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        failed_to_book_at: DateTime.now - (1.month + 1.second)
      )
      younger_failed_at = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        failed_to_book_at: DateTime.now - (1.month - 1.second)
      )
      no_failed_at = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        failed_to_book_at: nil
      )

      assert_difference('Tenancy.count', -1) do
        Tenancy.destroy_failed_to_book_tenancies_older_than(1.month)
      end
      assert Tenancy.where(id: no_failed_at.id).exists?
      assert Tenancy.where(id: younger_failed_at.id).exists?
      refute Tenancy.where(id: older_failed_at.id).exists?
    end
  end

  context '.competing_tenancies_for' do
    setup do
      setup_for_creating_tenancies
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

    should 'include all tenancies on the same room where end date is before our start date' do
      competitor = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('27/09/2021'),
        tenancy_end: Date.parse('27/09/2022')
      )
      previous_booking = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('26/05/2021'),
        tenancy_end: Date.parse('26/09/2021')
      )
      future_booking = Tenancy.create!(
        email: 'test@test.com',
        first_name: 'test',
        surname: 'test',
        room: @room,
        year: '21/22',
        tenancy_start: Date.parse('28/09/2022'),
        tenancy_end: Date.parse('28/09/2023')
      )

      output = Tenancy.competing_tenancies_for(@tenancy)
      assert_equal output, [competitor]
    end
  end

  context '#create_payment_items' do
    setup { setup_for_creating_tenancies }

    context 'monthly payment' do
      should 'create X payments of totalcost/X when number_of_payments is X' do
        tenancy = Tenancy.new(
          room: @room,
          deposit_term: 'monthly',
          year: '21/22',
          tenancy_start: Date.parse('27/09/2021'),
          monthly_price: 500,
          number_of_months: 3,
          number_of_payments: 3
        )
        tenancy.payment_edit = true
        tenancy.create_payment_items
        items = tenancy.tenancy_payment_items.sort_by(&:id)

        assert_equal 3, items.length
        payment_one = items.first
        payment_two = items.second
        payment_three = items.last

        assert_payment_equals(payment: payment_one, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/09/2021')
        assert_payment_equals(payment: payment_two, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/10/2021')
        assert_payment_equals(payment: payment_three, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/11/2021')
      end

      should 'create payments on the given day if rent_due_date is passed' do
        tenancy = Tenancy.new(
          room: @room,
          deposit_term: 'monthly',
          year: '21/22',
          rent_due_date: Date.parse('15/10/2021'),
          tenancy_start: Date.parse('27/09/2021'),
          monthly_price: 500,
          number_of_months: 3
        )
        tenancy.payment_edit = true
        tenancy.create_payment_items
        items = tenancy.tenancy_payment_items.sort_by(&:id)

        assert_equal 3, items.length
        payment_one = items.first
        payment_two = items.second
        payment_three = items.last

        assert_payment_equals(payment: payment_one, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '15/10/2021')
        assert_payment_equals(payment: payment_two, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '15/11/2021')
        assert_payment_equals(payment: payment_three, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '15/12/2021')
      end

      context 'when the tenant is a student' do
        context 'when there is an advanced rent payment' do
          should 'create an AvR payment alongside all the others' do
            tenancy = Tenancy.create!(
              email: 'tenant@test.com',
              first_name: 'billy',
              surname: 'bob',
              room: @room,
              deposit_term: 'monthly',
              tenancy_start: Date.parse('27/09/2021'),
              year: '21/22',
              weekly_price: 100,
              number_of_weeks: 15,
              number_of_payments: 2,
              tenant_type: 1,
              advanced_rent_payment_amount: 500,
              uri_string: 'test'
            )
            tenancy.payment_edit = true
            tenancy.create_payment_items
            items = tenancy.tenancy_payment_items.sort_by(&:id)

            assert_equal 3, items.length
            payment_one = items.first
            payment_two = items.second
            payment_three = items.last

            assert_payment_equals(payment: payment_one, item_type: 'monthly', item_year: '21/22', item: 'AvR', amount_due: 500, due_date: payment_one.created_at.to_date.to_s)
            assert_payment_equals(payment: payment_two, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/09/2021')
            assert_payment_equals(payment: payment_three, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/10/2021')
          end
        end

        context 'when there is no advanced rent payment' do
          should 'create payments using the weekly price, but for the number of months given' do
            tenancy = Tenancy.new(
              room: @room,
              deposit_term: 'monthly',
              year: '21/22',
              tenancy_start: Date.parse('27/09/2021'),
              weekly_price: 100,
              number_of_weeks: 15,
              number_of_months: 2,
              tenant_type: 1
            )
            tenancy.payment_edit = true
            tenancy.create_payment_items
            items = tenancy.tenancy_payment_items.sort_by(&:id)

            assert_equal 2, items.length
            payment_one = items.first
            payment_two = items.last

            assert_payment_equals(payment: payment_one, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 750, due_date: '01/09/2021')
            assert_payment_equals(payment: payment_two, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 750, due_date: '01/10/2021')
          end
        end
      end

      context 'when a payment amount is not present' do
        should 'create payments of the monthly price' do
          tenancy = Tenancy.new(
            room: @room,
            deposit_term: 'monthly',
            year: '21/22',
            tenancy_start: Date.parse('27/09/2021'),
            monthly_price: 500,
            number_of_months: 3
          )
          tenancy.payment_edit = true
          tenancy.create_payment_items
          items = tenancy.tenancy_payment_items.sort_by(&:id)

          assert_equal 3, items.length
          payment_one = items.first
          payment_two = items.second
          payment_three = items.last

          assert_payment_equals(payment: payment_one, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/09/2021')
          assert_payment_equals(payment: payment_two, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/10/2021')
          assert_payment_equals(payment: payment_three, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '01/11/2021')
        end
      end

      context 'when a payment amount is present' do
        should 'create payments of the payment amount' do
          tenancy = Tenancy.new(
            room: @room,
            deposit_term: 'monthly',
            year: '21/22',
            tenancy_start: Date.parse('27/09/2021'),
            payment_amount: 1000,
            number_of_months: 3
          )
          tenancy.payment_edit = true
          tenancy.create_payment_items
          items = tenancy.tenancy_payment_items.sort_by(&:id)

          assert_equal 3, items.length
          payment_one = items.first
          payment_two = items.second
          payment_three = items.last

          assert_payment_equals(payment: payment_one, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '01/09/2021')
          assert_payment_equals(payment: payment_two, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '01/10/2021')
          assert_payment_equals(payment: payment_three, item_type: 'monthly', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '01/11/2021')
        end
      end
    end

    context 'termly payment' do
      context 'when the tenant is a student' do
        context 'when there is an advanced rent payment' do
          should 'create an AvR payment alongside the others' do
            tenancy = Tenancy.create!(
              email: 'tenant@test.com',
              first_name: 'billy',
              surname: 'bob',
              room: @room,
              deposit_term: 'termly',
              year: '21/22',
              weekly_price: 100,
              number_of_weeks: 15,
              tenant_type: 1,
              advanced_rent_payment_amount: 600,
              uri_string: 'test',
              rent_installment_term: 3,
              term_due_dates: {
                "due_date_1(3i)"=>"30",
                "due_date_1(2i)"=>"9",
                "due_date_1(1i)"=>"2021",
                "due_date_2(3i)"=>"31",
                "due_date_2(2i)"=>"1",
                "due_date_2(1i)"=>"2022",
                "due_date_3(3i)"=>"30",
                "due_date_3(2i)"=>"8",
                "due_date_3(1i)"=>"2022"
              }
            )
            tenancy.payment_edit = true
            tenancy.create_payment_items
            items = tenancy.tenancy_payment_items.sort_by(&:id)

            assert_equal 4, items.length
            payment_one = items.first
            payment_two = items.second
            payment_three = items.third
            payment_four = items.last

            assert_payment_equals(payment: payment_one, item_type: 'termly', item_year: '21/22', item: 'AvR', amount_due: 600, due_date: payment_one.created_at.to_date.to_s)
            assert_payment_equals(payment: payment_two, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 300, due_date: '30/09/2021')
            assert_payment_equals(payment: payment_three, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 300, due_date: '31/01/2022')
            assert_payment_equals(payment: payment_four, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 300, due_date: '30/08/2022')
          end
        end

        context 'when there is no advanced rent payment' do
          should 'create 3 payments using the weekly price, not monthly' do
            tenancy = Tenancy.new(
              room: @room,
              deposit_term: 'termly',
              year: '21/22',
              tenancy_start: Date.parse('27/09/2021'),
              weekly_price: 100,
              number_of_weeks: 15,
              tenant_type: 1,
              rent_installment_term: 3,
              term_due_dates: {
                "due_date_1(3i)"=>"30",
                "due_date_1(2i)"=>"9",
                "due_date_1(1i)"=>"2021",
                "due_date_2(3i)"=>"31",
                "due_date_2(2i)"=>"1",
                "due_date_2(1i)"=>"2022",
                "due_date_3(3i)"=>"30",
                "due_date_3(2i)"=>"8",
                "due_date_3(1i)"=>"2022"
              }
            )
            tenancy.payment_edit = true
            tenancy.create_payment_items
            items = tenancy.tenancy_payment_items.sort_by(&:id)

            assert_equal 3, items.length
            payment_one = items.first
            payment_two = items.second
            payment_three = items.last

            assert_payment_equals(payment: payment_one, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '30/09/2021')
            assert_payment_equals(payment: payment_two, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '31/01/2022')
            assert_payment_equals(payment: payment_three, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 500, due_date: '30/08/2022')
          end
        end
      end

      context 'when a payment amount is not present' do
        should 'create 3 payments of a third of th monthly price * months, one for each of the due dates' do
          tenancy = Tenancy.new(
            room: @room,
            deposit_term: 'termly',
            year: '21/22',
            tenancy_start: Date.parse('27/09/2021'),
            monthly_price: 200,
            number_of_months: 6,
            rent_installment_term: 3,
            term_due_dates: {
              "due_date_1(3i)"=>"30",
              "due_date_1(2i)"=>"9",
              "due_date_1(1i)"=>"2021",
              "due_date_2(3i)"=>"31",
              "due_date_2(2i)"=>"1",
              "due_date_2(1i)"=>"2022",
              "due_date_3(3i)"=>"30",
              "due_date_3(2i)"=>"8",
              "due_date_3(1i)"=>"2022"
            }
          )
          tenancy.payment_edit = true
          tenancy.create_payment_items
          items = tenancy.tenancy_payment_items.sort_by(&:id)

          assert_equal 3, items.length
          payment_one = items.first
          payment_two = items.second
          payment_three = items.last

          assert_payment_equals(payment: payment_one, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 400, due_date: '30/09/2021')
          assert_payment_equals(payment: payment_two, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 400, due_date: '31/01/2022')
          assert_payment_equals(payment: payment_three, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 400, due_date: '30/08/2022')
        end
      end

      context 'when a payment amount is present' do
        should 'create 3 payments of the payment amount, one for each due date' do
          tenancy = Tenancy.new(
            room: @room,
            deposit_term: 'termly',
            year: '21/22',
            payment_amount: 1000,
            rent_installment_term: 3,
            term_due_dates: {
              "due_date_1(3i)"=>"30",
              "due_date_1(2i)"=>"9",
              "due_date_1(1i)"=>"2021",
              "due_date_2(3i)"=>"31",
              "due_date_2(2i)"=>"1",
              "due_date_2(1i)"=>"2022",
              "due_date_3(3i)"=>"30",
              "due_date_3(2i)"=>"8",
              "due_date_3(1i)"=>"2022"
            }
          )
          tenancy.payment_edit = true
          tenancy.create_payment_items
          items = tenancy.tenancy_payment_items.sort_by(&:id)

          assert_equal 3, items.length
          payment_one = items.first
          payment_two = items.second
          payment_three = items.last

          assert_payment_equals(payment: payment_one, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '30/09/2021')
          assert_payment_equals(payment: payment_two, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '31/01/2022')
          assert_payment_equals(payment: payment_three, item_type: 'termly', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '30/08/2022')
        end
      end
    end

    context 'full payment' do
      context 'when the tenant is a student' do
        context 'when there is an advanced rent payment' do
          should 'create an AvR payment alongside the others' do
            tenancy = Tenancy.create!(
              email: 'tenant@test.com',
              first_name: 'billy',
              surname: 'bob',
              room: @room,
              deposit_term: 'full',
              year: '21/22',
              tenancy_start: Date.parse('27/09/2021'),
              weekly_price: 100,
              number_of_weeks: 15,
              tenant_type: 1,
              advanced_rent_payment_amount: 200,
              uri_string: 'test'
            )
            tenancy.payment_edit = true
            tenancy.create_payment_items
            items = tenancy.tenancy_payment_items.sort_by(&:id)

            assert_equal 3, items.length
            payment_one = items.first
            payment_two = items.second
            payment_three = items.last

            assert_payment_equals(payment: payment_one, item_type: 'full', item_year: '21/22', item: 'AvR', amount_due: 200, due_date: payment_one.created_at.to_date.to_s)
            assert_payment_equals(payment: payment_two, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 650, due_date: '27/09/2021')
            assert_payment_equals(payment: payment_three, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 650, due_date: '27/10/2021')
          end
        end

        context 'when there is no advanced rent payment' do
          should 'create 2 payments using the weekly price' do
            tenancy = Tenancy.new(
              room: @room,
              deposit_term: 'full',
              year: '21/22',
              tenancy_start: Date.parse('27/09/2021'),
              weekly_price: 100,
              number_of_weeks: 15,
              tenant_type: 1
            )
            tenancy.payment_edit = true
            tenancy.create_payment_items
            items = tenancy.tenancy_payment_items.sort_by(&:id)

            assert_equal 2, items.length
            payment_one = items.first
            payment_two = items.last

            assert_payment_equals(payment: payment_one, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 750, due_date: '27/09/2021')
            assert_payment_equals(payment: payment_two, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 750, due_date: '27/10/2021')
          end
        end
      end

      context 'when a payment amount is not present' do
        should 'create 2 payments of the half the amount of the monthly price * months, one for tenancy start, one for a month after' do
          tenancy = Tenancy.new(
            room: @room,
            deposit_term: 'full',
            year: '21/22',
            tenancy_start: Date.parse('27/09/2021'),
            monthly_price: 500,
            number_of_months: 3
          )
          tenancy.payment_edit = true
          tenancy.create_payment_items
          items = tenancy.tenancy_payment_items.sort_by(&:id)

          assert_equal 2, items.length
          payment_one = items.first
          payment_two = items.last

          assert_payment_equals(payment: payment_one, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 750, due_date: '27/09/2021')
          assert_payment_equals(payment: payment_two, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 750, due_date: '27/10/2021')
        end
      end

      context 'when a payment amount is present' do
        should 'create 2 payments of the payment_amount, one for tenancy start, one for a month after' do
          tenancy = Tenancy.new(
            room: @room,
            deposit_term: 'full',
            year: '21/22',
            tenancy_start: Date.parse('27/09/2021'),
            payment_amount: 1000
          )
          tenancy.payment_edit = true
          tenancy.create_payment_items
          items = tenancy.tenancy_payment_items.sort_by(&:id)

          assert_equal 2, items.length
          payment_one = items.first
          payment_two = items.last

          assert_payment_equals(payment: payment_one, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '27/09/2021')
          assert_payment_equals(payment: payment_two, item_type: 'full', item_year: '21/22', item: 'Rent', amount_due: 1000, due_date: '27/10/2021')
        end
      end
    end
  end

  def assert_payment_equals(payment:, item_type:, item_year:, item:, amount_due:, due_date:)
    assert_equal item_type, payment.item_type
    assert_equal item_year, payment.item_year
    assert_equal item, payment.item
    assert_equal amount_due, payment.amount_due
    assert_equal Date.parse(due_date), payment.due_date
  end

  private

  def setup_for_creating_tenancies
    @landlord = Landlord.create!(contact_name: 'LL', email: 'landlord@test.com', partnership_format: 5)
    @property = Property.create!(landlord: @landlord, street: 'Street A', postcode: 'ABC 123')
    @room = Room.create!(property: @property, number: 1)
  end
end
