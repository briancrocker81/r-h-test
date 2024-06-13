Rails.application.routes.draw do

  resources :companies
  resources :property_utilities
  # get 'tenancy/sign_up'
  concern :attachable do
    resources :attachments, only: :create
  end

  resources :tenancies do
    resources :criminal_records
    resources :additional_tenants
    get :archived
    get :unarchived
    member do
      get :complete
      get :roll_next_year
      get :send_payment_items
      get :tenancy_payment_schedule
    end
  end
  resources :features
  # resources :tenants
  resources :events do
    collection do
      get :reminder
      get :done_reminder
    end
  end
  devise_for :users
  resources :rooms
  resources :listings
  resources :landlords do
    member do
      get :landlord_booking_report
      get :filter_booking_report
      get :send_booking_report
    end
  end
  resources :properties, concerns: [:attachable] do
    collection do
      get :get_properties
      get :get_available_properties
    end
    get :get_rooms
    get :get_filter_rooms
    get :edit_attachment
    patch :update_attachment
    member do
      resource :email_tenants_compliance_documents, only: :create, controller: 'properties/email_tenants_compliance_documents'
      get :resend_statement_report
      get :filter_landlord_statement
      get :filter_annual_landlord_statement
      get :generate_landlord_annual_statement
      get :send_email_to_tenants
    end
    resources :property_expenses, only: %w(new create destroy) do
      collection do
        get :filter_expense
      end
    end
    resources :rooms, only: [:new, :create, :index, :edit, :update] do
      member do
        get :sync
        get :sync_rightmove
        get :sync_zoopla
      end
    end
  end
  delete "remove_property_image/:property_id/:id", :to => "properties#remove_property_image", as: :remove_property_image
  get 'properties/:property_id/set_tenancy_form', to: 'properties#set_tenancy_form', as: :set_tenancy_form
  post 'properties/:property_id/set_tenancy', to: 'properties#set_tenancy', as: :set_tenancy
  get 'tenancies/:tenancy_id/mail_tenancy_dashboard_link', to: 'tenancies#mail_tenancy_dashboard_link', as: :mail_tenancy_dashboard_link

  resources :conversations, only: [:index, :create] do
    resources :messages, only: [:index, :create]
  end

  resources :messages
  resources :users
  post 'users/create', to: 'users#create', as: :create_new_user
  get 'users/new', to: 'users#new', as: :add_new_user

  get 'events_by_date', to: 'events#events_by_date'
  get 'welcome/index'
  get 'property/units/:status', to: 'welcome#properties', as: :property_units
  get 'calendar/index'

  get 'tenancies/tenancy_dashboard/:u_id', to: 'tenancies#tenancy_dashboard', as: :tenancy_dashboard
  #get 'tenancy/sign_up' #I do not know where to use it :)

  get 'tenancies/booking_form/:u_id', to: 'tenancies#booking_form', as: :booking_form
  post 'tenancies/submit_booking_form/:u_id', to: 'tenancies#submit_booking_form', as: :submit_booking_form

  get 'tenancies/agreement_form/:u_id', to: 'tenancies#agreement_form', as: :agreement_form
  post 'tenancies/submit_agreement_form/:u_id', to: 'tenancies#submit_agreement_form', as: :submit_agreement_form

  get 'tenancies/document_confirmation_form/:u_id', to: 'tenancies#document_confirmation_form', as: :document_confirmation_form
  post 'tenancies/document_confirmation/:u_id', to: 'tenancies#document_confirmation', as: :document_confirmation

  get 'tenancies/final_submission/:u_id', to: 'tenancies#final_submission', as: :submit_tenancy_form

  get 'tenancies/tenancy_dashboard/closed/:u_id', to: 'tenancies#closed_dashboard', as: :closed_dashboard

  get 'guarantors/guarantor_dashboard/:u_id', to: 'guarantors#guarantor_dashboard', as: :guarantor_dashboard

  get 'guarantors/agreement_form/:u_id', to: 'guarantors#agreement_form', as: :guarantor_agreement_form
  post 'guarantors/submit_agreement_form/:u_id', to: 'guarantors#submit_agreement_form', as: :guarantor_submit_agreement_form
  post 'confirm_tenancy_signed/:u_id', to: "guarantors#confirm_tenancy_signed", as: :confirm_signed_tenancy
  get 'guarantors/tenancy_agreement_form/:u_id', to: 'guarantors#tenancy_agreement_form', as: :guarantor_tenancy_agreement_form
  get 'guarantors/complete_guarantor_agreement/:u_id', to: 'guarantors#complete_guarantor_agreement', as: :complete_guarantor_agreement
  get 'mail_guarantor_dashboard_link', to: "guarantors#mail_guarantor_dashboard_link", as: :mail_guarantor_dashboard_link

  get 'reporting/index'
  get 'reporting/compliance_documents', to: 'reporting#compliance_documents', as: :reporting_compliance_documents
  get 'reporting/list_of_people_in_arrears', :to => 'reporting#list_of_people_in_arrears', as: :list_of_people_in_arrears
  get 'reporting/viewings', :to => 'reporting#viewings', as: :viewings
  get 'reporting/property_listings', :to => 'reporting#property_listings', as: :property_listings
  get 'reporting/tenancies', to: 'reporting#tenancies', as: :reporting_tenancies
  get 'reporting/combined_landlord_report', to: 'reporting#combined_landlord_report', as: :reporting_combined_landlord
  get "/print", to: "reporting#print_arrears", as: :print_arrears_report
  get "/send-arrear-report", to: "reporting#send_arrear_report", as: :send_arrear_report
  # get "/monthly-reports", to: "reporting#monthly_statement_report", as: :monthly_statement_reports
  # get "/send-property-report", to: "reporting#send_property_report", as: :send_property_report
  get "/set_custom_report_date", to: "reporting#set_custom_report_date", as: :set_custom_report_date
  get "/print-compliance-document", to: "reporting#print_compliance_report", as: :print_compliance_report
  get "/annual-commission-report", to: "reporting#annual_commission_report", as: :annual_commission_report
  get "/annual-rent-report", to: "reporting#annual_rent_report", as: :annual_rent_report
  get "/print-annual-rent-report", to: "reporting#print_annual_rent_report", as: :print_annual_rent_report
  get "/print-commission-income-report", to: "reporting#print_annual_commission_report", as: :print_annual_commission_report
  get "/sales-analysis-report", to: "reporting#sales_analysis_report", as: :sales_analysis_report
  get "/availability", to: "reporting#available_room", as: :available_room
  get "/print-availability", to: "reporting#print_available_room", as: :print_available_room
  get "/filter_sales_analysis_report", to: "reporting#filter_sales_analysis_report", as: :filter_sales_analysis_report
  get "print-sales-analysis-report", to: "reporting#print_sales_analysis_report", as: :print_sales_analysis_report
  get 'tenancy_payment_item_form/:tenancy_id', :to => 'tenancies#tenancy_payment_item_form', as: :tenancy_payment_item_form
  get "/monthly-payment-report", to: "reporting#monthly_payment_report", as: :monthly_payment_report
  get "/print-monthly-payment-report", to: "reporting#print_monthly_payment_report", as: :print_monthly_payment_report
  get "generate-monthly-payment-report",  to: "reporting#generate_monthly_payment_report", as: :generate_monthly_payment_report
  post 'tenancy_payment_item/:tenancy_id', :to => 'tenancies#tenancy_payment_item', as: :tenancy_payment_item
  delete 'tenancy_payment_item_delete/:item_id', :to => 'tenancies#tenancy_payment_item_delete', as: :tenancy_payment_item_delete
  resources :errors

  get 'filter_rooms', :to => 'rooms#filter_rooms', as: :filter_rooms

  resources :tenancy_staff_conversations, only: [:index, :new, :create] do
    resources :tenancy_staff_messages, only: [:index, :new, :create]
  end
  resources :tenancy_staff_messages

  ## admin section
  resource :admin, only: [] do
    get '/', to: 'admins#index'
    get '/generic-document', to: 'admins#generic_document'
    get '/system-signature', to: 'admins#system_signature'
    get :new_generic_document
    post :create_generic_document
    get :edit_generic_document
    delete :destroy_generic_document
    post :update_generic_document
    get :assign_generic_document
    get '/manage-automation-mail', to:'admins#manage_automation_mail'
    post :create_manage_automation_mail
    patch '/admin/update_manage_automation_mail/:id', to:'admins#update_manage_automation_mail', as: :update_manage_automation_mail
    get :open_automation_mail
    get :get_mail_options
    get :edit_automation_mail
    get :update_manage_automation
    get :sync_setting
    patch :update_sync_setting
    delete :delete_automation_mail
  end

  get 'tenancy_staff_messages/reply_form/:message_id', :to => 'tenancy_staff_messages#reply_form', as: :tenancy_staff_reply_form

  resources :landlord_staff_conversations, only: [:index, :new, :create] do
    resources :landlord_staff_messages, only: [:index, :new, :create]
  end
  resources :landlord_staff_messages

  get 'landlord_staff_messages/reply_form/:message_id', :to => 'landlord_staff_messages#reply_form', as: :landlord_staff_reply_form

  namespace :api do
    namespace :v1 do
      resources :properties, only: :index
    end
  end

  root 'welcome#index'
end
