# 結果画面を制御するクラス
# 1.回答を取得
# 2.回答から推定を行う
# 3.推定結果で結果（商品）を取得
# 4.結果のviewを呼ぶ
class ResultController < ApplicationController
    def index
        @ansarray=params[:postdata1]
        @qarray=params[:postdata2]
        # answerモデルに結果を代入
        for i in 0..4 do
            @answer=Answer.where(question_id: @qarray[2*i]).find_by_ansid(@ansarray[2*i]) || Answer.new(question_id: @qarray[2*i], ansid: @ansarray[2*i], count: 0)
            @answer.save
            n=@answer.count
            @answer.update(count: n+1)
        end
        
        #ベイズ
        #ベイズ確率の配列作成
        @bayes=Hash.new

        @gifts=Gift.all
        
        #ベイズ確率初期化
        @gifts.each do |gift|
            @bayes[gift]=0.5
        end
        
        
        #ベイズ計算
        for i in 0..4 do
          @gifts.each do |gift|
            @answer=Answer.where(question_id: @qarray[2*i]).find_by_ansid(@ansarray[2*i])
            @evaluation1=Evaluation.where(gift_id: gift.id).find_by_evalid(1) || Evaluation.new(gift_id: gift.id, evalid: 1, count: 0)
            @evaluation1.save
            @evaluation2=Evaluation.where(gift_id: gift.id).find_by_evalid(2) || Evaluation.new(gift_id: gift.id, evalid: 2, count: 0)
            @evaluation2.save
            @anstoeval1=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation1.id) || Anstoeval.new(answer_id: @answer.id, evaluation_id: @evaluation1.id, count: 1)
            @anstoeval1.save
            @anstoeval2=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation2.id) || Anstoeval.new(answer_id: @answer.id, evaluation_id: @evaluation2.id, count: 1)
            @anstoeval2.save
            p1=1.0*@anstoeval1.count/(@anstoeval1.count + @anstoeval2.count)
            @bayes[gift] = @bayes[gift]*p1/(@bayes[gift]*p1+(1-@bayes[gift])*(1-p1))
          end
        end
        
        #期待値と分散値の配列作成
        
        @giftExp  = Hash.new(1.0/2.0)
        @giftDisp = Hash.new(1.0/2.0)
        
        #期待値と分散値の配列に値を代入
        
        @gifts.each do |gift|
            # gift毎に[giftオブジェクト,期待値]のhash作成
            @giftExp[gift] = 1-2*@bayes[gift]
            # gift毎に[giftオブジェクト,分散値]のhash作成
            @giftDisp[gift] = @bayes[gift]*(-1-@giftExp[gift])**2+(1-@bayes[gift])*(1-@giftExp[gift])**2
        end
        
        #　期待値最大のgiftオブジェクト
        @gift1 = (@giftExp.sort_by{|key, value| -value}).to_a[0][0]
        #　分散値最大のgiftオブジェクト
        @gift2 = (@giftDisp.sort_by{|key, value| -value}).to_a[0][0]
        #期待値上位3件取得
        @gift1Top3=[]
        for i in 0..2
        @gift1Top3[i] = (@giftExp.sort_by{|key, value| -value}).to_a[i][0]
        end
        
        #分散値上位3件を期待値上位3件と被らないように取得
        @gift2Top3=[]
        n=0
        for i in 0..2
         while @gift1Top3[0]==(@giftDisp.sort_by{|key, value| -value}).to_a[n][0] || @gift1Top3[1]==(@giftDisp.sort_by{|key, value| -value}).to_a[n][0] || @gift1Top3[2]==(@giftDisp.sort_by{|key, value| -value}).to_a[n][0] do
          n+=1
         end
         @gift2Top3[i] = (@giftDisp.sort_by{|key, value| -value}).to_a[n][0]
         n+=1
        end
        
        #デフォルトでgiftの評価は1(bad)にする
        for i in 0..4 do
            @answer=Answer.where(question_id: @qarray[2*i]).find_by_ansid(@ansarray[2*i])
            e1up(@gift1,@answer)
            e1up(@gift2,@answer)
        end
        # @evaluation1=Evaluation.where(gift_id: @gift1.id).find_by_evalid(1)
        # @evaluation2=Evaluation.where(gift_id: @gift2.id).find_by_evalid(1)
        # for i in 0..4 do
        #   @answer=Answer.where(question_id: @qarray[2*i]).find_by_ansid(@ansarray[2*i])
        #   @anstoeval1=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation1.id)
        #   @anstoeval2=Anstoeval.where(answer_id: @answer.id).find_by_evaluation_id(@evaluation2.id)
        #   cntup(@anstoeval1)
        #   cntup(@anstoeval2)
        # end
    end
    
    
    def countup
        gid=params[:gift]
        gans=params[:gift_ans]
        gq=params[:gift_q]
        for i in 0..4
          @answer=Answer.where(question_id: gq[2*i]).find_by_ansid(gans[2*i])
          e1down(Gift.find(gid),@answer)
          e2up(Gift.find(gid),@answer)
         end
        
        render text: "Succeedup! Gift"+gid
        
    end
    
    def countdown
        gid=params[:gift]
        gans=params[:gift_ans]
        gq=params[:gift_q]
        for i in 0..4
          @answer=Answer.where(question_id: gq[2*i]).find_by_ansid(gans[2*i])
          e2down(Gift.find(gid),@answer)
          e1up(Gift.find(gid),@answer)
        end
        render text: "Succeeddown! Gift"+gid
    end
    
    private
        def e2up(gift,answer)
            evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(2)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
            n=anstoeval.count
            anstoeval.update(count: n+1)
        end
        def e2down(gift,answer)
            evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(2)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
            n=anstoeval.count
            anstoeval.update(count: n-1)
        end
        def e1up(gift,answer)
            evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(1)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
            n=anstoeval.count
            anstoeval.update(count: n+1)
        end
        def e1down(gift,answer)
            evaluation=Evaluation.where(gift_id: gift.id).find_by_evalid(1)
            anstoeval=Anstoeval.where(answer_id: answer.id).find_by_evaluation_id(evaluation.id)
            n=anstoeval.count
            anstoeval.update(count: n-1)
        end
end
