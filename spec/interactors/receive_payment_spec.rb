require 'spec_helper'
require 'accounting_helper'

describe ReceivePayment do
  now = DateTime.parse '2015-06-06'

  before do
    Timecop.freeze now
  end

  after do
    Timecop.return
  end

  it 'creates a payment accounting activity' do
    loan = create_disbursed_loan(500)
    ReceivePayment.execute!(loan, 200)
    activity = AccountingActivity.last

    expect(activity.amount).to eq(200)
    expect(activity.to_accounting_bucket.name).to eq('payments')
    expect(activity.activity_type).to eq(AccountingActivity::TYPES[:receive_payment])
    expect(activity.effective_date).to eq(now)
  end
end
