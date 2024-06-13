class TenancyPaymentItem < ApplicationRecord
  belongs_to :tenancy
  before_save :set_arrears_value

  amoeba do
    nullify :amount_paid
    nullify :arrears
    nullify :payment_method
    nullify :date_paid

    customize(lambda { |original_post,new_post|
      new_post.due_date = original_post.due_date + 365
      last_year = original_post.item_year
      year = last_year.split('/')
      new_post.item_year = "#{year[1]}/#{year[1].to_i + 1}"
    })
  end

  filterrific(
    default_filter_params: { sorted_by: 'tenancy_name_asc' },
    available_filters: [
      :sorted_by,
      :search_query
    ]
  )

  default_scope { joins(:tenancy).where('tenancies.archived = ?', false) }
  scope :number_of_people_in_arrears_today, -> { where('due_date <= ? ',  Time.now.to_date).where.not('arrears = ? or arrears = ? or arrears = ? ', "0.0", "0", "") }
  scope :search_query, ->(query) {
    return nil  if query.blank?
    num_or_conditions = 4
    terms = query.to_s.downcase.split(/\s+/)
    terms = terms.map{|term| term.gsub(/\*$/, '')}.map{|term| "%#{term}%"}
    where(
      terms.map {  |term|
        "LOWER(tenancies.first_name) LIKE ? OR LOWER(tenancies.surname) LIKE ? OR tenancies.email LIKE ? OR tenancies.mobile LIKE ?"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    ).left_joins(:tenancy)
  }
  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^amount_due/
      order("amount_due #{direction}")
    when /^tenancy_name/
      order("tenancies.first_name #{direction}")
    when /^arrears/
      order("arrears #{direction}")
    when /^overdue_days/
      order("due_date #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Tenant Name (A - Z)', 'tenancy_name_asc'],
      ['Tenant Name (Z - A)', 'tenancy_name_desc'],
      ['Overdue days (Low - High)', 'overdue_days_asc'],
      ['Overdue days (High - Low)', 'overdue_days_desc'],
      ['Amount due (Low - High)', 'amount_due_asc'],
      ['Amount due (High - Low)', 'amount_due_desc'],
      ['Arrears (Low - High)', 'arrears_asc'],
      ['Arrears (High - Low)', 'arrears_desc']
    ]
  end

  def set_arrears_value
    if amount_paid_changed? || amount_due_changed?
      self.arrears = (amount_due.to_f - amount_paid.to_f).round(2) if due_date < Date.today
    end
  end

  def update_arrears(amount)
    self.update_column(:arrears, amount)
  end

  def update_arrears_to_nil
    self.update_column(:arrears, '')
  end
end
