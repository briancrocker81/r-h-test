class AddFinalSubmissionAtToTenancies < ActiveRecord::Migration[5.2]
  def up
    add_column :tenancies, :final_submission_at, :datetime
    Tenancy.where(final_submission: true).update_all(final_submission_at: DateTime.now)
  end

  def down
    remove_column :tenancies, :final_submission_at
  end
end
