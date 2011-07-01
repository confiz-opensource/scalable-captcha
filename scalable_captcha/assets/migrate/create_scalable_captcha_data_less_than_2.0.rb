# Copyright (c) 2011 [Sur http://www.confiz.com]

class CreateScalableCaptchaData < ActiveRecord::Migration
  def self.up
    create_table :scalable_captcha_data do |t|
      t.column :key, :string, :limit => 40
      t.column :value, :string, :limit => 6
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :scalable_captcha_data
  end
end
