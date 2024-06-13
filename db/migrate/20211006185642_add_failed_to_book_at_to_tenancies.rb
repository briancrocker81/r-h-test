class AddFailedToBookAtToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :failed_to_book_at, :datetime
  end
end
