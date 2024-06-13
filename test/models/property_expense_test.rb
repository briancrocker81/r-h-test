require 'test_helper'

class PropertyExpenseTest < ActiveSupport::TestCase
  context '.for_last_month' do
    setup do
      landlord = Landlord.create!(contact_name: 'test', email: 'test@test.com', partnership_format: 'Owned')
      @property = Property.create!(landlord: landlord, street: '1', postcode: '1234')
    end

    should 'return expenses where expense date was in the previous month' do
      PropertyExpense.create!(property: @property, name: 'before', category: 0, expense_date: Date.parse('2021-09-30'))
      expected = PropertyExpense.create!(property: @property, name: 'current', category: 0, expense_date: Date.parse('2021-10-30'))
      PropertyExpense.create!(property: @property, name: 'after', category: 0, expense_date: Date.parse('2021-11-01'))
      Timecop.freeze DateTime.parse('2021-11-01 14:51') do
        output = PropertyExpense.for_last_month
        assert_equal [expected], output
      end
    end
  end
end
