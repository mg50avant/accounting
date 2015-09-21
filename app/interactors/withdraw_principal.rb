class WithdrawPrincipal
  def self.execute!(loan, withdrawal_amount)
    bucket = loan.accounting_bucket_by_name('outstanding_principal')

    AccountingActivity.create!(:amount => withdrawal_amount,
                               :to_accounting_bucket => bucket,
                               :activity_type => AccountingActivity::TYPES[:withdrawal],
                               :effective_date => DateTime.current)

  end
end
