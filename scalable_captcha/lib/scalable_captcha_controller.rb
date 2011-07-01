# Copyright (c) 2011 [Sur http://www.confiz.com]

class ScalableCaptchaController < ActionController::Base
  layout nil

  include ScalableCaptcha::ImageHelpers

  def scalable_captcha  #:nodoc
    settings = ScalableCaptcha::ConfigTasks.captcha_settings
    file_path = "#{settings["image_path"]}/#{ScalableCaptchaData.find_by_key(params[:scalable_captcha_key]).id}.gif"
    raise "Invalid Captcha Path: #{file_path}" unless File.exists?(file_path)
    send_data(File.read(file_path),
      :type => 'image/gif',
      :filename => 'scalable_captcha.jpg')
  end

end
