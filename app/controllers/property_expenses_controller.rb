class PropertyExpensesController < ApplicationController
  include Pagy::Backend

  before_action :set_property, only: %w(new create destroy filter_expense)

  def new
    @property_expense = @property.property_expenses.new
  end

  def create
    date = Date.parse(params[:property_expense][:expense_date])
    year = date.strftime('%y').to_i
    month = date.strftime('%m').to_i
    params[:property_expense][:year] = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
    @property_expense = @property.property_expenses.new(property_expense_params)
    all_property_expenses
  end

  def destroy
    @property_expense = @property.property_expenses.find_by(id: params[:id])
    @property_expense.destroy if @property_expense
    all_property_expenses
    redirect_to property_path(@property), notice: 'Expense has been deleted successfully!'
  end

  def filter_expense
    all_property_expenses
    if @year.present?
      @year_id = params[:year].to_s.gsub('/', '-')
      @property_expenses = @property_expenses.where('year = ?', @year)
    else
      @year_id = @year
    end
  end

  private

  def all_property_expenses
    @year = params[:year] ? params[:year] : @current_year
    @property_expenses = @property.property_expenses
  end

  def set_property
    @property =  Property.includes(:property_expenses).find_by(id: params[:property_id])
    redirect_to properties_path, alert: 'Property has been not found!' if @property.blank?
  end

  def property_expense_params
    params.require(:property_expense).permit(:name, :expense_date, :recurring, :category, :amount, :number_of_months, :file, :year)
  end
end
