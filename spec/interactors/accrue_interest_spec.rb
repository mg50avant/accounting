require 'spec_helper'

describe AccrueInterest do
  let!(:loan) { CreateLoan.execute!(600) }

  context 'loan is not disbursed' do
    it 'raises an exception' do
      expect { AccrueInterest.execute!(loan) }.to raise_exception
    end
  end

  context 'loan is disbursed' do
    before do
      DisburseLoan.execute!(loan)
      loan
        .accounting_bucket_by_name('outstanding_principal')
        .update_column(:current_balance, 500)
    end

    it 'creates an interest accrual accounting activity based on the outstanding principal bucket' do
      AccrueInterest.execute!(loan)
      activity = AccountingActivity.last
      expect(activity.amount.truncate(2)).to eq(BigDecimal('0.47'))
      expect(activity.to_accounting_bucket).to eq(loan.accounting_bucket_by_name('accruing_interest'))
      expect(activity.activity_type).to eq(AccountingActivity::TYPES[:accrue_interest])
    end
  end
end
