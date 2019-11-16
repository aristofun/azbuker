class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      #t.database_authenticatable :null => false
      t.string :email, :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      #t.recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      #t.rememberable
      t.datetime :remember_created_at

      #t.trackable
      t.integer :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      #t.confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email # Only if using reconfirmable

      #t.token_authenticatable
      t.string :authentication_token

      t.timestamps
    end

    add_index :users, :email, :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token, :unique => true
    # add_index :users, :unlock_token,         :unique => true
    add_index :users, :authentication_token, :unique => true
  end

end
