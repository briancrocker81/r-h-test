require "prawn"
require 'prawn/table'
class ListingPdf < Prawn::Document

  TABLE_WIDTHS = [100, 100]
  PAGE_MARGIN = [40, 40, 40, 40]


  def initialize(agreements=[], filterrific_year = @current_year, status = '' )
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, :page_layout => :landscape)
    @status = status
    @rooms = agreements
    @filterrific_year = filterrific_year
    display_table
  end

  private

  def display_table
    if table_data.empty?
      text "None data"
    else
      table(table_data,column_widths: TABLE_WIDTHS, :cell_style => { size: 10 } )
    end
  end

  def table_data
    @table_data ||= room_rows
  end

  def room_rows
    tenancy_rows = []
    tenancy_rows << ['Property', 'Room No', 'List £', 'Booked £', 'Size', 'Type', 'Start', 'End','Name', 'Mobile', 'Email', 'Availability', 'Accepted', 'Signed']
    @rooms.map do |room|
      if room.tenancies.count >= 1
        tenancies = get_tenancies_btwn_years(room)
        if tenancies[:tenant_present].present?
          tenancies[:tenancies].each do |tenancy|
            tenancy_rows << [room.property.property_name.gsub(",","-"), tenancy.room.number,
                             "£#{room.list_price}", "£#{tenancy.payment_amount}",
            tenancy.room.property.number_of_bedrooms,
            tenancy.tenancy_is_nice_name, tenancy.tenancy_start.strftime('%d %b %y'), tenancy.tenancy_end.strftime('%d %b %y'),
                             tenancy.tenant_name,
            tenancy.mobile, tenancy.email, (room.availability? ? 'Yes' : 'No'),
            (tenancy.accept_agreement? ? "Yes" : "No"),
            (tenancy.signed_tenancy_agreement? ? "Yes" : "No")]
          end
        else
          tenancy_rows << [room.property.property_name.gsub(",","-"), room.number, "£#{room.list_price}", '', room.property.number_of_bedrooms, ' ', ' ', ' ', ' ', ' ', ' ', (room.availability? ? 'Yes' : 'No'), ' ', ' ']
        end
      else
        tenancy_rows << [room.property.property_name.gsub(",","-"), room.number, "£#{room.list_price}", '', room.property.number_of_bedrooms, ' ', ' ', ' ', ' ', ' ', ' ', (room.availability? ? 'Yes' : 'No'), ' ', ' ']
      end
    end
    return tenancy_rows
  end

  def get_tenancies_btwn_years(room)
    tenancies = room.tenancies.where("tenancies.year= ?", @filterrific_year).order(:tenancy_start)
    tenancies = tenancies.where("tenancies.booking_status = ?", @status) if [1, 2].include?(@status)
    if tenancies.count >= 1
      {tenancies: tenancies, tenant_present: true}
    else
      {tenancies: "", tenant_present: false}
    end
  end
end
