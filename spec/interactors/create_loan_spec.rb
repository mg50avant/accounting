require 'spec_helper'

describe CreateLoan do
  let!(:loan) { CreateLoan.execute!(500) }

  it 'creates a new loan' do
    expect(Loan.count).to eq(1)
  end

  it 'creates the loan with correct status and principal amount' do
    expect(loan.current_status).to eq(Loan::STATUS[:new])
    expect(loan.principal_amount).to eq(500)
    expect(loan.apr).to eq(BigDecimal(BigDecimal('0.35')))
  end

  it 'creates the relevant accounting buckets alongside the loan' do
    buckets = loan.accounting_buckets
    expect(buckets.map(&:name).sort).to eq(['accruing_interest',
                                            'outstanding_interest',
                                            'outstanding_principal',
                                            'payments'])
    expect(buckets.map(&:current_balance)).to eq([0, 0, 0, 0])
  end
end
