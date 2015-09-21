class InterestCalculator
  def calculate_daily_interest(apr, outstanding_principal)
    BigDecimal(apr * outstanding_principal / 365)
  end
end
