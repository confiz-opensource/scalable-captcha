# Copyright (c) 2011 [Sur http://www.confiz.com]

require 'digest/sha1'

module ScalableCaptcha #:nodoc
  module ConfigTasks #:nodoc

    def self.captcha_settings
      @@_scalable_catpcha_settings ||= begin
        @settings = {
          "image_path" => "#{RAILS_ROOT}/vendor/plugins/scalable_captcha/assets/images/scalable_captcha",
          "image_pool" => 100,
          "destroy_captcha_images" => true,
          "sleep_time" => 2,
          "image_options" => {
            "image_type" => "simply_blue",
            "code_type" => "alphabetic",
            "distortion" => "low",
          }
        }
        if File.exists?("#{RAILS_ROOT}/config/scalable_captcha.yml")
          yml = YAML.load_file("#{RAILS_ROOT}/config/scalable_captcha.yml")
          if yml[RAILS_ENV].blank?
            raise "Invalid YAML settings."
          else
            @settings.merge!(yml[RAILS_ENV])

            #change the relative path to rails root
            if @settings["image_path"][0].chr != "/"
              @settings["image_path"] = "#{RAILS_ROOT}/#{@settings["image_path"]}"
            end
          end
        end
        @settings
      end
    end
    
    private
    def scalable_captcha_image_path #:nodoc
      @settings["image_path"]
    end
    
    def scalable_captcha_key #:nodoc
      return session[:scalable_captcha] if session[:scalable_captcha]
      captcha_data = ScalableCaptchaData.first :select=>"min(id) as min_id, max(id) as max_id"
      scalable_data = ScalableCaptchaData.find(rand(captcha_data.max_id.to_i - captcha_data.min_id.to_i) + captcha_data.min_id.to_i)
      session[:scalable_captcha] = scalable_data.key
    end
        
    def scalable_captcha_value(key = scalable_captcha_key) #:nodoc
      ScalableCaptchaData.find_by_key(key).value
    end
  end  
end
