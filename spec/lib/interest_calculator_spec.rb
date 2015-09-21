require 'spec_helper'

describe InterestCalculator do
  it 'calculates interest based on APR' do
    apr = BigDecimal('0.35')
    outstanding_principal = 500
    calculator = InterestCalculator.new

    result = calculator.calculate_daily_interest(apr, outstanding_principal)

    expect(result.truncate(2)).to eq(BigDecimal('0.47'))
  end
end
