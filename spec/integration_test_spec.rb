require 'spec_helper'

describe 'integration test' do
  it 'correctly runs an entire schedule' do
    # Create a new loan
    loan = CreateLoan.execute!(500)

    # Disburse loan the night of the 31st
    on('2014-12-31') { DisburseLoan.execute!(loan) }

    start_date = Date.parse '2015-01-01'
    end_date = Date.parse '2015-01-30'

    (start_date..end_date).each do |date|
      on(date) do
        if date.to_s == '2015-01-15'
          ReceivePayment.execute!(loan, 200)
        elsif date.to_s == '2015-01-25'
          WithdrawPrincipal.execute!(loan, 100)
        end

        DailyAccounting.execute!(loan)
      end
    end

    total_interest = loan.accounting_balances[:accruing_interest] +
                     loan.accounting_balances[:outstanding_interest]

    expect(loan.accounting_balances[:outstanding_principal]).to eq(BigDecimal('400'))
    expect(total_interest.round(2)).to eq(BigDecimal('11.99'))
  end

  def on(date, &blk)
    Timecop.freeze date.to_s
    blk.call
    Timecop.return
  end
end
