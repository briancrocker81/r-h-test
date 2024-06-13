require "prawn"
require 'prawn/table'
class LandlordPdf < Prawn::Document

  TABLE_WIDTHS = [100, 100]
  PAGE_MARGIN = [40, 40, 40, 40]


  def initialize(landlords)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, :page_layout => :landscape)
    @landlords = landlords
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
    @table_data ||= landlord_rows
  end

  def landlord_rows
    [['Landlord', 'Contact No', 'Email', 'Partner Type']] +
      @landlords.map do | landlord |
        [landlord.contact_name, (landlord.contact_number == "" ? "N/A" : landlord.contact_number), landlord.email, landlord.partnership_format]
    end
  end

end
