class AccountingBucket < ActiveRecord::Base
  has_many :accounting_activities

  belongs_to :loan
end
