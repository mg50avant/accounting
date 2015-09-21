class AccrueInterest
  def self.execute!(loan)
    ActiveRecord::Base.transaction do
      raise unless loan.current_status == Loan::STATUS[:disbursed]

      outstanding_principal = loan.accounting_bucket_by_name('outstanding_principal')
      accruing_interest_bucket = loan.accounting_bucket_by_name('accruing_interest')
      calculator = InterestCalculator.new
      amount = calculator.calculate_daily_interest(loan.apr, outstanding_principal.current_balance)

      AccountingActivity.create!(
        :amount => amount,
        :to_accounting_bucket => accruing_interest_bucket,
        :activity_type => AccountingActivity::TYPES[:accrue_interest],
        :effective_date => DateTime.current)
    end
  end
end
