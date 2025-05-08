class NotesController < ApplicationController
  @@page_size = 25
  @@captcha_string = "Support trans rights"

  def index
    @current_page = Integer(params[:page] || 0)
    @page_size = @@page_size
    if !current_user
      redirect_to new_note_path
    else 
      @notes = Note.all.limit(@@page_size).offset(@current_page * @@page_size ).all
    end
  end

  def show
    @note = Note.find(params[:id])
    if !@note.public 
      assert_logged_in
    end
  end

  def submitted
    
  end

  def new
    @captcha_string = @@captcha_string
    @note = Note.new
  end

  def create
    @captcha_string = @@captcha_string
    captcha = params[:iamhuman]
    @entry = Note.new(entry_params)
    if captcha != @captcha_string && !current_user
      @errors = "That 'thing' (you know the one) has to say '#{@captcha_string}'. Exactly."
      render :new, status: :unprocessable_entity
      return
    end
    if @entry.save
      redirect_to notes_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])
    if @note.update(entry_params)
      redirect_to @note
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    assert_logged_in 
    @entry = Note.find(params[:id])
    @entry.destroy

    redirect_to notes_path, status: :see_other
  end

  private

  def entry_params
    if current_user
      params.require(:note).permit(:subject, :body, :contact, :homesite, :public)
    else 
      params.require(:note).permit(:subject, :body, :contact, :homesite)
    end
  end

  def assert_logged_in
    if !current_user
      return redirect_to login_path
    end
  end
end
