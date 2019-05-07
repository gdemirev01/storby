class CreateCreditCards < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_cards do |t|
      t.string :first_name
      t.string :last_name
      t.string :number
      t.string :expiration_month
      t.string :expiration_year
      t.string :card_security_code
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
