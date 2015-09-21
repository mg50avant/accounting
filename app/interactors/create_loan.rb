class CreateLoan
  def self.execute!(principal_amount)
    ActiveRecord::Base.transaction do
      loan = Loan.new(:principal_amount => principal_amount,
                      :current_status => Loan::STATUS[:new],
                      :apr => BigDecimal('0.35')) # Hardcoded to 35% for the sake of this exercise

      buckets = loan.accounting_buckets
      buckets.build(:name => 'outstanding_principal', :current_balance => 0)
      buckets.build(:name => 'outstanding_interest', :current_balance => 0)
      buckets.build(:name => 'accruing_interest', :current_balance => 0)
      buckets.build(:name => 'payments', :current_balance => 0)

      loan.save!
      loan
    end
  end
end
