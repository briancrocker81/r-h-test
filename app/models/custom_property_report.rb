class CustomPropertyReport < ApplicationRecord

  ## validation
  validates :start_date, :end_date, presence: true

  ## Association
  belongs_to :user, foreign_key: :run_by_id
end
