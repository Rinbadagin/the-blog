class WebringNodeController < ApplicationController
  before_action :assert_logged_in, except: %i[index show transfemring]
  skip_before_action :verify_authenticity_token, only: %i[transfemring]

  def index
    @nodes = WebringNode.all
    if request.format.json?
      render json: @nodes.map { |node| 
        node.slice(:id, :site_link, :author, :in_the_ring, :created_at) 
      }
    end
  end

  def show
    @webring_node = WebringNode.find(params[:id])
  end

  def new
    @webring_node = WebringNode.new
  end

  def create
    @webring_node = WebringNode.new(node_params)
    if @webring_node.save
      redirect_to webring_node_index_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @webring_node = WebringNode.find(params[:id])
  end

  def update
    @webring_node = WebringNode.find(params[:id])
    if @webring_node.update(node_params)
      redirect_to webring_node_index_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @webring_node.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def node_params
    params.require(:webring_node).permit(:description, :site_link, :author, :in_the_ring, :notes, :banner)
  end

  def assert_logged_in
    if !current_user
      return redirect_to login_path
    end
  end
end

