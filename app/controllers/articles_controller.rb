class ArticlesController < ApplicationController
  before_action :set_sidebar_data
  before_action :assert_logged_in, except: %i[index show index_json]

  def index
    @index_article = Article.find(1)
  end

  def index_json
    render json: Article.all.where(visibility: true)
  end

  def show
    @article = Article.find(params[:id])
    assert_logged_in if !@article.visibility
    if request.content_type == "application/json"
      render json: @article
    end
  end

  def new
    @article = Article.new visibility: false
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if params[:id] == 1
      render json: { error: "Article 1 cannot be deleted as it is the index" }
      return
    end
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :visibility)
  end

  def set_sidebar_data
    @articles = Article.all.sort_by &:title
  end

  def assert_logged_in
    if !current_user
      return redirect_to login_path
    end
  end
end
