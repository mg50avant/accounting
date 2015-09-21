require 'spec_helper'

describe DisburseLoan do
  let!(:loan) { CreateLoan.execute!(500) }

  it 'raises an exception if the loan is not new' do
    loan.update_column :current_status, Loan::STATUS[:disbursed]
    expect { DisburseLoan.execute!(loan) }.to raise_exception
  end

  it 'changes the loan status to "disbursed" and sets initial billing date' do
    DisburseLoan.execute!(loan)
    expect(loan.current_status).to eq(Loan::STATUS[:disbursed])
    expect(loan.next_billing_date).to eq(Date.today + 30)
  end

  it 'creates an accounting activity for the disbursement' do
    DisburseLoan.execute!(loan)
    expect(AccountingActivity.count).to eq(1)

    activity = AccountingActivity.last
    expect(activity.to_accounting_bucket.name).to eq('outstanding_principal')
    expect(activity.amount).to eq(loan.principal_amount)
    expect(activity.activity_type).to eq(AccountingActivity::TYPES[:withdrawal])
    expect(activity.effective_date).to eq(Date.current)

  end
end
