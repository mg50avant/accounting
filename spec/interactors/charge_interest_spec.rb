require 'spec_helper'
require 'accounting_helper'

describe ChargeInterest do
  now = DateTime.parse '2015-06-06'

  before do
    Timecop.freeze now
  end

  after do
    Timecop.return
  end

  it 'creates an interest charge accounting activity' do
    loan = create_disbursed_loan 500, :outstanding_interest => 200, :accruing_interest => 100
    ChargeInterest.execute!(loan)
    activity = AccountingActivity.last

    expect(activity.amount).to eq(100)
    expect(activity.to_accounting_bucket.name).to eq('outstanding_interest')
    expect(activity.from_accounting_bucket.name).to eq('accruing_interest')
    expect(activity.activity_type).to eq(AccountingActivity::TYPES[:charge_interest])
    expect(activity.effective_date).to eq(now)
  end

  it 'updates the next billing date of the loan' do
    loan = create_disbursed_loan 500
    billing_date_before = loan.next_billing_date
    ChargeInterest.execute!(loan)
    billing_date_after = loan.next_billing_date

    expect(billing_date_after).to eq(billing_date_before + 30)
  end

  it 'talks to the bank API' do
    expect(BankAPIFacade).to receive(:charge!)

    loan = create_disbursed_loan 500
    ChargeInterest.execute!(loan)

  end
end
