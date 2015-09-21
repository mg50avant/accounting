class CreateTables < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.string :current_status
      t.decimal :principal_amount
      t.decimal :current_outstanding_balance
      t.decimal :apr
      t.date :next_billing_date
      t.timestamps :null => false
    end

    create_table :accounting_buckets do |t|
      t.integer :loan_id, :null => false
      t.string :name
      t.decimal :current_balance
      t.timestamps :null => false
    end

    create_table :accounting_activities do |t|
      t.integer :to_accounting_bucket_id, :null => false
      t.integer :from_accounting_bucket_id, :null => true
      t.decimal :amount
      t.string :activity_type
      t.date :effective_date
      t.timestamps :null => false
    end
  end
end
