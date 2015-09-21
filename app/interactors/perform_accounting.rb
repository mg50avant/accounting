class PerformAccounting
  def self.execute!(loan)
    activities = loan
                 .accounting_activities
                 .where(:effective_date => Date.today)

    new_balances = Accountant.new.calculate_new_balances(loan.accounting_balances, activities)
    new_balances.each do |bucket_name, amount|
      bucket = loan.accounting_bucket_by_name(bucket_name.to_s)
      bucket.update_attributes!(:current_balance => amount)
    end
  end
end
