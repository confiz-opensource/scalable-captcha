# Copyright (c) 2011 [Sur http://www.confiz.com]

module ScalableCaptcha #:nodoc 
  module ControllerHelpers #:nodoc
    
    include ConfigTasks
    
    # This method is to validate the scalable captcha in controller.
    # It means when the captcha is controller based i.e. :object has not been passed to the method show_scalable_captcha.
    #
    # *Example*
    #
    # If you want to save an object say @user only if the captcha is validated then do like this in action...
    #
    #  if scalable_captcha_valid?
    #   @user.save
    #  else
    #   flash[:notice] = "captcha did not match"
    #   redirect_to :action => "myaction"
    #  end
    def scalable_captcha_valid?
      return true if RAILS_ENV == 'test'
      if params[:captcha]
        scalable_captcha_value(session[:scalable_captcha]) == params[:captcha].delete(" ").upcase
      else
        false
      end
    end
    
  end
end
