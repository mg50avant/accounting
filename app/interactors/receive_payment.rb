class ReceivePayment
  def self.execute!(loan, payment_amount)
    payment_bucket = loan.accounting_bucket_by_name('payments')

    AccountingActivity.create!(:amount => payment_amount,
                               :to_accounting_bucket => payment_bucket,
                               :activity_type => AccountingActivity::TYPES[:receive_payment],
                               :effective_date => DateTime.current)
  end
end
