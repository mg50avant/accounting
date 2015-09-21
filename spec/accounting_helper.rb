def create_disbursed_loan(principal_amount, amounts_by_bucket={})
  loan = CreateLoan.execute!(principal_amount)
  DisburseLoan.execute!(loan)

  bucket_names = [:outstanding_principal, :outstanding_interest, :accruing_interest,
                  :payments]

  bucket_names.each do |bucket_name|
    loan
      .accounting_bucket_by_name(bucket_name.to_s)
      .update_column :current_balance, (amounts_by_bucket[bucket_name] || 0)
  end

  loan
end
