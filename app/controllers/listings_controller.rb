class ListingsController < ApplicationController
  include Pagy::Backend
  require 'csv'
  require 'securerandom'

  def index
    @all_rooms = Room.joins(:property).ids
    @rooms = Room.joins(:property)
    @filterrific = initialize_filterrific(
      @rooms,
      params[:filterrific],
      select_options: {
        sorted_by: @rooms.options_for_sorted_by
      },
      persistence_id: "rooms_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @rooms = @filterrific.find

    respond_to do |format|
      format.js do
        @pagy, @rooms = pagy(@rooms, items: 100)
      end
      format.html do
        @pagy, @rooms = pagy(@rooms, items: 100)
      end
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"listings.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
      format.pdf do
        status = ''
        if @filterrific.room_availability.present?
          status = 0 if @filterrific.room_availability.room_available == '1'
          status = 1 if @filterrific.room_availability.room_booked == '1'
          status = 2 if @filterrific.room_availability.room_complete == '1'
          status = 3 if @filterrific.room_availability.room_expired == '1'
        end

        selected_year = !params[:filterrific].nil? ? params[:filterrific][:room_availability][:search_by_year_range] : @current_year
        pdf = ListingPdf.new(@rooms, selected_year, status)

        if params[:mail] == "false"
          send_data pdf.render, filename: 'listings.pdf', type: 'application/pdf'
        else
          filename = "#{"listings-"+SecureRandom.hex(8)+".pdf"}"
          pdf.render_file(filename)
          TenancyMailer.list_mailer(filename).deliver
          redirect_to(reset_filterrific_url(format: :html)) && return
        end
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end
end
