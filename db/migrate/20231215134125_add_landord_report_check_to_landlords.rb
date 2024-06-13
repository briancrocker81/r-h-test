class AddLandordReportCheckToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :send_report, :boolean
  end
end
