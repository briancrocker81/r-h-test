class AddAppointmentInfoToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :appointment_info, :string
  end
end
