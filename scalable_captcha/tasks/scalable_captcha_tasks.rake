# Copyright (c) 2011 [Sur http://www.confiz.com]

require 'fileutils'

namespace :scalable_captcha do
  desc "Set up the plugin ScalableCaptcha for rails < 2.0"
  task :setup_old => :environment do
    ScalableCaptcha::SetupTasks.do_setup(:old)
  end
  
  desc "Set up the plugin ScalableCaptcha for rails >= 2.0"
  task :setup => :environment do
    ScalableCaptcha::SetupTasks.do_setup
  end

  desc "Generate random keys and images for local storage"
  task :generate_images => :environment do
    @settings = ScalableCaptcha::ConfigTasks.captcha_settings
    generate_random_images
  end
end

# The available options to modify are:
# * image_syle
# * distortion
# * code_type
#
# <b>Image Style:</b>
#
# There are eight different styles of images available as...
# * embosed_silver
# * simply_red
# * simply_green
# * simply_blue
# * distorted_black
# * all_black
# * charcoal_grey
# * almost_invisible
#
# The default image is simply_blue and can be modified in scalable_captcha.yml
#
# <b>Distortion:</b>
#
# There are three different options available as...
# * low
# * medium
# * high
#
# The default distortion is medium and can be modified in scalable_captcha.yml
#
# <b>Code Type</b>
#
# There are three different options available as...
# * alphabetic e.g ZSKSRE
# * numeric e.g 124523
# * math e.g 3 + 5
#
# The default code type is alphabetic and can be modified in scalable_captcha.yml

def generate_random_images
  file_path = @settings["image_path"]

  #clear old cache
  if @settings["destroy_captcha_images"]
    ScalableCaptchaData.connection.execute("TRUNCATE TABLE #{ScalableCaptchaData.table_name}")

    #clear local directory for images
    FileUtils.rm_r(file_path) if File.exists? file_path
  end
  
  FileUtils.mkdir file_path unless File.exists? file_path
  
  #generate image accordingly to random number ... and this should be done only once.
  generated_image = Magick::Image.new(110, 30)  

  @settings["image_pool"].to_i.times do
    @image = generated_image.clone
   
    value = generate_scalable_captcha_data(@settings["image_options"]["code_type"])
    key = Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s)

    data = ScalableCaptchaData.find_by_key(key) || ScalableCaptchaData.new(:key => key)
    data.value = eval(value)
    data.save

    @scalable_captcha_image_options = {
      :scalable_captcha_key => key,
      :color => "darkblue",
      :distortion => ScalableCaptcha::ImageHelpers.distortion(@settings["image_options"]["distortion"]),
      :image_style => ScalableCaptcha::ImageHelpers.image_style(@settings["image_options"]["image_style"])
    }
    set_scalable_captcha_image_style(value)

    #save image to local file
    @image = @image.add_noise(Magick::ImpulseNoise)
    @image.write("#{@settings["image_path"]}/#{data.id}.gif")
    puts "generated: #{@settings["image_path"]}/#{data.id}.gif"
    sleep(@settings["sleep_time"].to_i)
  end
end

def append_scalable_captcha_code(captcha_value) #:nodoc
  color = @scalable_captcha_image_options[:color]
  text = Magick::Draw.new
  text.annotate(@image, 0, 0, 0, 5, captcha_value) do
    self.font_family = 'arial'
    self.pointsize = 22
    self.fill = color
    self.gravity = Magick::CenterGravity
  end
end

def generate_scalable_captcha_data(code)
  value = case code
  when 'numeric'
    6.times{value << (49 + rand(9)).chr}
    "'#{value}'"
  when 'math'
    get_random_math_exp
  else #alphabets
    6.times{value << (65 + rand(26)).chr}
    "'#{value}'"
  end
  return value
end

def set_scalable_captcha_image_style(captcha_value) #:nodoc
  amplitude, frequency = @scalable_captcha_image_options[:distortion]
  case @scalable_captcha_image_options[:image_style]
  when 'embosed_silver'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency).shade(true, 20, 60)
  when 'simply_red'
    @scalable_captcha_image_options[:color] = 'darkred'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency)
  when 'simply_green'
    @scalable_captcha_image_options[:color] = 'darkgreen'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency)
  when 'simply_blue'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency)
  when 'distorted_black'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency).edge(10)
  when 'all_black'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency).edge(2)
  when 'charcoal_grey'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency).charcoal
  when 'almost_invisible'
    @scalable_captcha_image_options[:color] = 'red'
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency).solarize
  else
    append_scalable_captcha_code(captcha_value)
    @image = @image.wave(amplitude, frequency)
  end
end

def get_random_math_exp
  "#{(49 + rand(9)).chr} #{[:+, :-, :*].sort_by{rand}.first} #{(49 + rand(9)).chr}"
end
  
def init_configs
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
end

    