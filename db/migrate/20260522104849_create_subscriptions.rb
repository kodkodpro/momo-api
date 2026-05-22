# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.belongs_to :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :transaction_id, null: false
      t.integer :status, null: false, limit: 2
      t.jsonb :data, null: false, default: {}
      t.datetime :refreshed_at, null: false
      t.timestamps
    end

    add_index :subscriptions, :transaction_id, unique: true
    add_index :subscriptions, :status
  end
end
