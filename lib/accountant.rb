class Accountant
  def calculate_new_balances(balances, activities)
    new_balances = balances.dup

    # Every payment activity gives us an accounting bucket (like
    # outstanding principal) and a payment amount to add to it.
    activities.each do |activity|
      amount = activity.amount
      to_bucket_name = activity.to_accounting_bucket.name.to_sym
      from_bucket_name = activity.from_accounting_bucket.try(:name).try(:to_sym)

      new_balances[to_bucket_name] += amount
      new_balances[from_bucket_name] -= amount if from_bucket_name
    end

    waterfall_payments(new_balances)
  end

  private
  def waterfall_payments(balances)
    payment = balances[:payments]
    outstanding_principal = balances[:outstanding_principal]
    outstanding_interest = balances[:outstanding_interest]
    accruing_interest = balances[:accruing_interest]

    # First we pay down the outstanding principal.
    new_principal = [outstanding_principal - payment, 0].max
    payment_remaining_after_principal =
      [payment - outstanding_principal, 0].max

    # If any of the payment is left over, we pay down outstanding interest.
    new_outstanding_interest =
      [outstanding_interest - payment_remaining_after_principal, 0].max
    payment_remaining_after_outstanding_interest =
      [payment_remaining_after_principal - outstanding_interest, 0].max

    # Any leftover payment now goes to accruing interest.
    new_accruing_interest =
      [accruing_interest - payment_remaining_after_outstanding_interest, 0].max
    payment_remaining =
      [payment_remaining_after_outstanding_interest - accruing_interest, 0].max

    { :outstanding_principal => new_principal,
      :outstanding_interest => new_outstanding_interest,
      :accruing_interest => new_accruing_interest,
      :payments => payment_remaining
    }
  end
end
