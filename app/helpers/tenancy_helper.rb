module TenancyHelper
  def get_tenants_name(room)
    name = ''
    room.tenancy.each do |tenant|
      name += name + tenant.tenant_full_name
    end
    return name
  end

  def check_landlord(landlord)
    value = {}
    if ['Owned'].include? landlord.partnership_format
      value = { bank_name: landlord.bank_name, bank_address: landlord.bank_address, sort_code: landlord.bank_sort_code,
                account_name: landlord.account_name, account_number: landlord.bank_account_number, iban: landlord.iban,
                bic: landlord.bic }
    elsif ['Tenancy Partner', 'Booking Partner','Listing Partner', 'Complete Partner', 'Support Partner'].include? landlord.partnership_format
      value = landlord.pay_direct ? { bank_name: landlord.bank_name, bank_address: landlord.bank_address,
                                      sort_code: landlord.bank_sort_code, account_name: landlord.account_name,
                                      account_number: landlord.bank_account_number, iban: landlord.iban,
                                      bic: landlord.bic } : { bank_name: "Lloyds",
                                                              bank_address: "Royal Parade, Plymouth, PL1 1DS",
                                                              sort_code: "30-96-68", account_name: "CityLets Plymouth LTD",
                                                              account_number: "88212563", iban: "GB92 LOYD 30966 8882 12563",
                                                              bic: "LOYDGB21082" }
    else
      value = {bank_name: "N/A", bank_address: "N/A", sort_code: "N/A",
                account_name: "N/A", account_number: "N/A", iban: "N/A",
                bic: "N/A"
              }
    end
    return value
  end

  def total_rental_amount(tenancy)
    if tenancy.tenancy_payment_items.count > 0
      number_with_delimiter(sprintf("%.2f",(tenancy.tenancy_payment_items.sum(:amount_due)*10).ceil/10.0), delimiter: ',')
    else
      tenancy.tenancy_is == 0 ? number_with_delimiter(sprintf("%.2f",(tenancy.weekly_price.to_f * tenancy.number_of_weeks.to_f).ceil), delimiter: ',') : number_with_delimiter(sprintf("%.2f",(tenancy.monthly_price.to_f * tenancy.number_of_months.to_f).ceil), delimiter: ',')
    end
  end

  def card_number(card_no)
    card_no = card_no.to_s
    l_val = card_no.last(4)
    f_val = card_no[0..-5]
    return (admin? || finance? ? card_no : (f_val.gsub(/\S/, '*') + l_val) )
  end

  def card_cvc(cvc)
    cvc = cvc.to_s
    return (admin? || finance? ? cvc : cvc.gsub(/\S/, '*') )
  end

  def advance_date(tenancy)
    adv_pay_date = tenancy.tenancy_payment_items.find_by(item: 'AvR')
    if tenancy.advanced_rent_payment_date
      tenancy.advanced_rent_payment_date.strftime("%d/%m/%Y")
    elsif adv_pay_date
      adv_pay_date.due_date&.strftime("%d/%m/%Y")
    else
      '<span style="color:red;">Wrong date format given</span>'.html_safe
    end
  end
end
