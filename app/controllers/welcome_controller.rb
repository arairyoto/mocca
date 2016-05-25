class WelcomeController < ApplicationController
    before_action do
        #端末によってViewファイルを振り分ける
        if request.user_agent.include?("Mobile") then
            request.variant = :mobile
        else
        end
        # case params[:device]
        # when 'tablet'
        #   request.variant = :tablet
        # when 'mobile'
        #   request.variant = :mobile
        # end
    end
    
    def index
    end
    
    def new
        @gifts=Gift.order("created_at DESC").limit(6)
    end
    
    def info
    end
    
end
