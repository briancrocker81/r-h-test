class PropertyExpense < ApplicationRecord
  ## Uploader
  mount_uploader :file, AttachmentUploader

  ## Enum
  enum category: %w(Utility Works Other)
  enum status: %w(Start Done)

  ## Association
  belongs_to :property


  ## validation
  validates :expense_date, :name, :category, presence: true
  validates :amount,  numericality: true, presence: true
  validates :number_of_months, numericality: true, allow_blank: true
  validate :expense_number_of_months

  ## Default Scope
  default_scope { order(expense_date: :asc) }

  scope :for_last_month, ->() { where(expense_date: Date.today.prev_month.at_beginning_of_month..Date.today.prev_month.at_end_of_month) }

  ## Custom validation
  def expense_number_of_months
    errors.add(:number_of_months, "is not valid for single expense") if recurring == false && number_of_months.present?
  end
end
