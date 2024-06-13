module TenanciesHelper

  def get_tenancy_payment_items(tenancy)
    payment_items = tenancy.archived ? TenancyPaymentItem.unscoped.where(tenancy_id: tenancy.id).order(:due_date) : tenancy.tenancy_payment_items.order(:due_date)
    if tenancy.deposit_term == "monthly" || tenancy.rent_payment_option == 1 || tenancy.rent_payment_option == "1"
      payment_items.where(item_type: 'monthly').order('id asc')
    elsif tenancy.deposit_term == "termly" || tenancy.rent_payment_option == 0 || tenancy.rent_payment_option == "0"
      payment_items.where(item_type: 'termly').order('id asc')
    elsif tenancy.deposit_term == "full" || tenancy.rent_payment_option == 2 || tenancy.rent_payment_option == "2"
      payment_items.where(item_type: 'full').order('id asc')
    else
      []
    end
  end

  def rent_option(option)
    if option == "0" || option == 0
      "Termly"
    elsif option == "1" || option == 1
      "Monthly"
    elsif option == "2" || option == 2
      "Full"
    else
      'Not Defined'
    end
  end

  def check_for_arrears_update(pay_item)
    amount_due = pay_item.amount_due.to_f
    amount_paid = pay_item.amount_paid.to_f
    pay_item.update_arrears(amount_due - amount_paid)
    TenancyPaymentItem.find pay_item.id
  end

  def get_tenant_year(tenant_id)
    Tenancy.where(id: tenant_id).pluck(:year)
  end
end
