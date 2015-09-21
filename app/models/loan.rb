class Loan < ActiveRecord::Base
  has_many :accounting_buckets

  STATUS = {
    :new => 'new',
    :disbursed => 'disbursed',
    :paid => 'paid'
  }

  def accounting_activities
    AccountingActivity.where(:to_accounting_bucket_id => accounting_buckets.map(&:id))
  end

  def accounting_bucket_by_name(name)
    accounting_buckets.find { |bucket| bucket.name == name }
  end

  def accounting_balances
    balances = {}
    accounting_buckets.each do |bucket|
      balances[bucket.name.to_sym] = bucket.current_balance
    end

    balances
  end

  def paid_off?
    balances = accounting_balances

    balances[:outstanding_principal] +
      balances[:outstanding_interest] +
      balances[:accruing_interest] == 0
  end
end
