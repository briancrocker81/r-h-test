class ForRemoveBookingStatusAndRenamedBookedStatus < ActiveRecord::Migration[5.2]
  def change
    Tenancy.all.each do |tenancy|
      p tenancy.id
      p tenancy.booking_status
      tenancy.booking_status = 'booking' if tenancy.booking_status == 'booked'
      tenancy.booking_status = 'available' if tenancy.booking_status == ''
      tenancy.update_column(:booked_status, tenancy.booking_status)
      puts '=================='
    end
    remove_column :tenancies, :booking_status
    rename_column :tenancies, :booked_status, :booking_status
  end
end
