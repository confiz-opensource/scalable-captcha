# Copyright (c) 2011 [Sur http://www.confiz.com]

class CreateScalableCaptchaData < ActiveRecord::Migration
  def self.up
    create_table :scalable_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
      t.timestamps
    end
  end

  def self.down
    drop_table :scalable_captcha_data
  end
end
