class AddNikSkypePhoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string, :null => false, :limit => 20
    add_column :users, :skypename, :string, :limit => 34
    add_column :users, :phone, :string, :limit => 25
    add_column :users, :cityid, :integer, :default => -1, :null => false

    add_column :users, :admin, :boolean, :default => false
    
    add_index :users, :nickname, :unique => true
  end

  #validates_format_of :home_phone, :work_phone,
  #  :message => "must be a valid telephone number.",
  #  :with => /^[\(\)0-9\- \+\.]{10,20}$/
end
