# 質問のフローを制御するクラス
  # 1.質問をDBから取得
  # 2.質問の型を変換
  # 3.Questionのviewを呼ぶ
class QflowController < ApplicationController
    
    before_action do
        #端末によってViewファイルを振り分ける
        if (request.user_agent.include?("Mobile") || request.user_agent.include?("iPhone")) || request.user_agent.include?("Android") then
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
        reset_session
        @questions=Question.order("RANDOM()").limit(5)
        @qs=Question.all
        #質問で使用されてたら1されてなければ0のバリューを持つ
        @hQuestions=Hash.new
        @qs.each do |q|
            if @questions.include?(q) then
                @hQuestions[q]=1
            else
                @hQuestions[q]=0
            end
        end
        #sessionでQハッシュの管理
        session[:questions]=code_session(@hQuestions)
        
        
    end
    
    def continue
        @qs=Question.all
        @hQuestions=decode_session(session[:questions])
        
        @q_notused=@hQuestions.select {|k, v| v == 0 }.keys

        @questions=@q_notused.sample(5)
        
        @qs.each do |q|
            case @hQuestions[q]
            when 1 then
            when 0 then
                if @questions.include?(q) then
                    @hQuestions[q]=1
                else
                    @hQuestions[q]=0
                end
            else
            end
        end

        session[:questions]=code_session(@hQuestions)
        render 'index'
        
    end
    private
    def code_session(hash)
        nhash=Hash.new
        hash.each_key do |key|
            nhash[key.id]=hash[key]
        end
        return nhash
    end
    def decode_session(hash)
        nhash=Hash.new
        hash.each_key do |key|
            nhash[Question.find(key)]=hash[key]
        end
        return nhash
    end
    
end
