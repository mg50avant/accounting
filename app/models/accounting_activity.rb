class AccountingActivity < ActiveRecord::Base
  belongs_to :to_accounting_bucket, :class_name => 'AccountingBucket', :foreign_key => :to_accounting_bucket_id
  belongs_to :from_accounting_bucket, :class_name => 'AccountingBucket', :foreign_key => :from_accounting_bucket_id

  TYPES = {
    :accrue_interest => 'accrue_interest',
    :charge_interest => 'charge_interest',
    :withdrawal => 'withdrawal',
    :receive_payment => 'receive_payment'
  }
end
