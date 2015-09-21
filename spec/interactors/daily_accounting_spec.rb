require 'spec_helper'
require 'accounting_helper'

describe DailyAccounting do
  let!(:loan) { create_disbursed_loan(500) }

  after do
    Timecop.return
  end

  it 'raises an exception unless the lone is disbursed' do
    loan.update_column :current_status, Loan::STATUS[:new]

    expect { described_class.execute!(loan) }.to raise_error
  end

  it 'tries to accrue interest' do
    expect(AccrueInterest).to receive(:execute!).with(loan)
    described_class.execute!(loan)
  end

  it 'charges interest if the billing date is today' do
    Timecop.freeze loan.next_billing_date.to_s
    expect(ChargeInterest).to receive(:execute!).with(loan)
    described_class.execute!(loan)
  end

  it 'marks a loan as paid off if all relevant balances are 0' do
    bucket = loan.accounting_bucket_by_name('payments')
    AccountingActivity.create(:to_accounting_bucket => bucket,
                              :amount => BigDecimal('700'),
                              :effective_date => Date.today)
    described_class.execute!(loan)
    expect(loan.current_status).to eq(Loan::STATUS[:paid])
  end
end
