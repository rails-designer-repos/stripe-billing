class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :customer_id, null: false
      t.string :subscription_id, null: false
      t.datetime :cancel_at, null: true
      t.datetime :current_period_end_at, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
