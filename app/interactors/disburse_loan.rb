class DisburseLoan
  def self.execute!(loan)
    ActiveRecord::Base.transaction do
      raise unless loan.current_status == Loan::STATUS[:new]

      loan.current_status = Loan::STATUS[:disbursed]
      loan.next_billing_date = Date.today + 30.days
      WithdrawPrincipal.execute!(loan, loan.principal_amount)
      loan.save!
      PerformAccounting.execute!(loan)
    end
  end
end
