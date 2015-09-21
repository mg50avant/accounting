class DailyAccounting
  def self.execute!(loan)
    ActiveRecord::Base.transaction do
      raise unless loan.current_status == Loan::STATUS[:disbursed]

      AccrueInterest.execute!(loan)
      ChargeInterest.execute!(loan) if loan.next_billing_date == Date.today
      PerformAccounting.execute!(loan)

      if loan.paid_off?
        loan.update_attributes!(:current_status => Loan::STATUS[:paid])
      end
    end
  end
end
