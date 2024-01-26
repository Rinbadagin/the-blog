class UploadsController < ApplicationController
  before_action :assert_logged_in, except: %i[show]

  def index
    @uploads = Upload.all
  end

  def show
    @upload = Upload.find(params[:title]) #find_by(title: params[:title])
  end

  def new
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(upload_params)
    if @upload.save
      redirect_to uploads_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @upload = Upload.find(params[:title])
    @upload.destroy

    redirect_to upload_path, status: :see_other
  end

  private 
    def upload_params
      params.require(:upload).permit(:title, :description, :content)
    end

    def assert_logged_in
      if !current_user 
        return redirect_to login_path
      end
    end
end
