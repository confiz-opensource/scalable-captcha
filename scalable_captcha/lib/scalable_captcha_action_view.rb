# Copyright (c) 2011 [Sur http://www.confiz.com]

module ScalableCaptcha #:nodoc
  module ViewHelpers #:nodoc
    
    include ConfigTasks

    # Simple Captcha is a very simplified captcha.
    #
    # It can be used as a *Controller* based Captcha depending on what options
    # we are passing to the method show_scalable_captcha.
    #
    # *show_scalable_captcha* method will return the image, the label and the text box.
    # This method should be called from the view within your form as...
    #
    # <%= show_scalable_captcha %>
    #
    # The available options to pass to this method are
    # * label
    #
    # <b>Label:</b>
    #
    # default label is "type the text from the image", it can be modified by passing :label as
    #
    # <%= show_scalable_captcha(:label => "new captcha label") %>.
    #
    # *Examples*
    # * controller based
    # <%= show_scalable_captcha( :label => "Human Authentication: type the text from image above") %>
    #
    # All Feedbacks/CommentS/Issues/Queries are welcome.
    def show_scalable_captcha(options={})
      options[:field_value] = set_scalable_captcha_data
      @scalable_captcha_options = 
        {:image => scalable_captcha_image(options),
        :label => options[:label] || "(type the code from the image)",
        :field => scalable_captcha_field(options)}
      render :partial => 'scalable_captcha/scalable_captcha'
    end

    private

    def scalable_captcha_image(options={})
      url = 
        scalable_captcha_url(
        :action => 'scalable_captcha',
        :scalable_captcha_key => options[:field_value],
        :time => Time.now.to_i)
      "<img src='#{url}' alt='scalable_captcha.jpg' />"
    end
    
    def scalable_captcha_field(options={})
      options[:object] ?
        text_field(options[:object], :captcha, :value => '') +
        hidden_field(options[:object], :captcha_key, {:value => options[:field_value]}) :
        text_field_tag(:captcha)
    end

    def set_scalable_captcha_data
      captcha_data = ScalableCaptchaData.first :select=>"min(id) as min_id, max(id) as max_id"
      scalable_data = ScalableCaptchaData.find(rand(captcha_data.max_id.to_i - captcha_data.min_id.to_i) + captcha_data.min_id.to_i)
      session[:scalable_captcha] = scalable_data.key
    end
  end
end

ActionView::Base.module_eval do
  include ScalableCaptcha::ViewHelpers
end
