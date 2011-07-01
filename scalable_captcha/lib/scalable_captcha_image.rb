# Copyright (c) 2011 [Sur http://www.confiz.com]

require 'rubygems'
require 'RMagick'

module ScalableCaptcha #:nodoc
  module ImageHelpers #:nodoc
    
    include ConfigTasks
    
    IMAGE_STYLES = [
      'embosed_silver',
      'simply_red',
      'simply_green',
      'simply_blue',
      'distorted_black',
      'all_black',
      'charcoal_grey',
      'almost_invisible'
    ]
    
    DISTORTIONS = ['low', 'medium', 'high']

    class << self
      def image_style(key='simply_blue')
        return IMAGE_STYLES[rand(IMAGE_STYLES.length)] if key=='random'
        IMAGE_STYLES.include?(key) ? key : 'simply_blue'
      end
      
      def distortion(key='low')
        key = 
          key == 'random' ?
          DISTORTIONS[rand(DISTORTIONS.length)] :
          DISTORTIONS.include?(key) ? key : 'low'
        case key
          when 'low' then return [0 + rand(2), 80 + rand(20)]
          when 'medium' then return [2 + rand(2), 50 + rand(20)]
          when 'high' then return [4 + rand(2), 30 + rand(20)]
        end
      end
    end
    
  end
end
