require 'spec_helper'
require 'accounting_helper'

describe Accountant do
  describe '#calculate_new_balances' do
    let!(:loan) {
      create_disbursed_loan(500, outstanding_principal: BigDecimal('500'),
                            outstanding_interest: BigDecimal('100'),
                            interest_accruing: BigDecimal('0'),
                            payments: BigDecimal('0'))
    }

    let(:payments_bucket) { loan.accounting_bucket_by_name('payments') }
    let(:outstanding_principal_bucket) { loan.accounting_bucket_by_name('outstanding_principal') }
    let(:outstanding_interest_bucket) { loan.accounting_bucket_by_name('outstanding_interest') }
    let(:accruing_interest_bucket) { loan.accounting_bucket_by_name('accruing_interest') }

    let(:accountant) { Accountant.new }

    it 'modifies balances for a one activity' do
      activities = [AccountingActivity.create(:amount => BigDecimal('1.0'),
                                              :to_accounting_bucket => accruing_interest_bucket)
                   ]

      result = accountant.calculate_new_balances(loan.accounting_balances, activities)
      expect(result[:outstanding_principal]).to eq(BigDecimal('500'))
      expect(result[:accruing_interest]).to eq(BigDecimal('1.0'))
    end

    it 'modifies balances for multiple activities' do
      activities = [AccountingActivity.create(:amount => BigDecimal('1.0'),
                                              :to_accounting_bucket => accruing_interest_bucket),
                    AccountingActivity.create(:amount => BigDecimal('10.0'),
                                              :to_accounting_bucket => outstanding_principal_bucket)
                   ]

      result = accountant.calculate_new_balances(loan.accounting_balances, activities)
      expect(result[:outstanding_principal]).to eq(BigDecimal('510.0'))
      expect(result[:accruing_interest]).to eq(BigDecimal('1.0'))
    end

    it 'subtracts from buckets when appropriate' do
      activities = [AccountingActivity.create(:amount => BigDecimal('10.0'),
                                              :to_accounting_bucket => accruing_interest_bucket),
                    AccountingActivity.create(:amount => BigDecimal('10.0'),
                                              :to_accounting_bucket => outstanding_interest_bucket,
                                              :from_accounting_bucket => accruing_interest_bucket)
                   ]

      result = accountant.calculate_new_balances(loan.accounting_balances, activities)
      expect(result[:outstanding_interest]).to eq(BigDecimal('110.0'))
      expect(result[:accruing_interest]).to eq(BigDecimal('0.0'))

    end

    it 'waterfalls payments to pay down other balances' do
      activities = [AccountingActivity.create(:amount => BigDecimal('10.0'),
                                              :to_accounting_bucket => outstanding_principal_bucket),
                    AccountingActivity.create(:amount => BigDecimal('550.0'),
                                              :to_accounting_bucket => payments_bucket)
                   ]

      result = accountant.calculate_new_balances(loan.accounting_balances, activities)
      expect(result[:outstanding_principal]).to eq(BigDecimal('0'))
      expect(result[:outstanding_interest]).to eq(BigDecimal('60'))
      expect(result[:payments]).to eq(BigDecimal('0'))
    end
  end

  describe '#waterfall_payments' do
    let(:balances) {{
      outstanding_principal: BigDecimal('200'),
      outstanding_interest: BigDecimal('100'),
      accruing_interest: BigDecimal('50'),
      payments: @payment_amount
    }}

    let(:resulting_balances) {
      Accountant.new.send(:waterfall_payments, balances)
    }

    it 'first attempts to pay down principal' do
      @payment_amount = 50
      expect(resulting_balances).to eq outstanding_principal: BigDecimal('150'),
                                       outstanding_interest: BigDecimal('100'),
                                       accruing_interest: BigDecimal('50'),
                                       payments: 0
    end

    it 'pays down outstanding interest after principal' do
      @payment_amount = 250
      expect(resulting_balances).to eq outstanding_principal: BigDecimal('0'),
                                       outstanding_interest: BigDecimal('50'),
                                       accruing_interest: BigDecimal('50'),
                                       payments: 0
    end

    it 'pays down accruing interest after outstanding interest' do
      @payment_amount = 325
      expect(resulting_balances).to eq outstanding_principal: BigDecimal('0'),
                                       outstanding_interest: BigDecimal('0'),
                                       accruing_interest: BigDecimal('25'),
                                       payments: 0
    end

    it 'holds on to extra payment' do
      @payment_amount = 400
      expect(resulting_balances).to eq outstanding_principal: BigDecimal('0'),
                                       outstanding_interest: BigDecimal('0'),
                                       accruing_interest: BigDecimal('0'),
                                       payments: BigDecimal('50')
    end
  end
end
