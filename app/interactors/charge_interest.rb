class ChargeInterest
  def self.execute!(loan)
    ActiveRecord::Base.transaction do
      outstanding_interest = loan.accounting_bucket_by_name('outstanding_interest')
      accruing_interest = loan.accounting_bucket_by_name('accruing_interest')
      amount = accruing_interest.current_balance

      AccountingActivity.create!(:amount => amount,
                                 :to_accounting_bucket => outstanding_interest,
                                 :from_accounting_bucket_id => accruing_interest.id,
                                 :activity_type => AccountingActivity::TYPES[:charge_interest],
                                 :effective_date => DateTime.current)

      BankAPIFacade.charge!(loan, amount) # This is currently a no-op

      loan.next_billing_date += 30
      loan.save!
    end
  end
end
