class AnstoevalsController < ApplicationController
  before_action :set_anstoeval, only: [:show, :edit, :update, :destroy]
  
  before_action do
    PERMIT_ADDRESSES = ['127.0.0.1', '::1', '115.165.80.15' , ENV['MY_IP_ADDRESS'], ENV['MY_SUB_IP_ADDRESS'], ENV['H_IP_ADDRESS']].freeze

    unless PERMIT_ADDRESSES.include?(request.remote_ip)
      render text: 'Service Unavailable', status: 503
    end
  end
  
  layout 'home'

  def index
    @anstoevals = Anstoeval.all
  end

  def show
  end

  def new
    @anstoeval = Anstoeval.new
  end

  # GET /anstoevals/1/edit
  def edit
  end

  # POST /anstoevals
  # POST /anstoevals.json
  def create
    @anstoeval = Anstoeval.new(anstoeval_params)

    respond_to do |format|
      if @anstoeval.save
        format.html { redirect_to @anstoeval, notice: 'anstoeval was successfully created.' }
        format.json { render :show, status: :created, location: @anstoeval }
      else
        format.html { render :new }
        format.json { render json: @anstoeval.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /anstoevals/1
  # PATCH/PUT /anstoevals/1.json
  def update
    respond_to do |format|
      if @anstoeval.update(anstoeval_params)
        format.html { redirect_to @anstoeval, notice: 'anstoeval was successfully updated.' }
        format.json { render :show, status: :ok, location: @anstoeval }
      else
        format.html { render :edit }
        format.json { render json: @anstoeval.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /anstoevals/1
  # DELETE /anstoevals/1.json
  def destroy
    @anstoeval.destroy
    respond_to do |format|
      format.html { redirect_to anstoevals_url, notice: 'anstoeval was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_anstoeval
      @anstoeval = Anstoeval.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def anstoeval_params
      params.require(:anstoeval).permit(:count)
    end
end

