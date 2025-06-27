class GuestbookController < ApplicationController
  before_action :assert_logged_in, except: %i[index new create]
  @@page_size = 15
  @@captcha_string = "I support trans rights :3"
  
  def index
    @current_page = Integer(params[:page] || 0)
    @page_size = @@page_size
    @entries = GuestbookEntry.order(created_at: :desc).limit(@@page_size).offset(@current_page * @@page_size ).all
  end

  def new
    @captcha_string = @@captcha_string
    @entry = GuestbookEntry.new
  end

  def create
    @captcha_string = @@captcha_string
    captcha = params[:iamhuman]
    @entry = GuestbookEntry.new(entry_params)
    if captcha != @captcha_string 
      @errors = "That 'thing' (you know the one) has to say '#{@captcha_string}'. Exactly."
      render :new, status: :unprocessable_entity
    elsif @entry.save
      redirect_to guestbook_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    assert_logged_in 
    @entry = GuestbookEntry.find(params[:id])
    @entry.destroy

    redirect_to guestbook_index_path, status: :see_other
  end

  private 
    def entry_params
      params.require(:guestbook_entry).permit(:name, :body, :home_site, :contact, :hide_contact_from_public)
    end

    def assert_logged_in
      if !current_user 
        return redirect_to login_path
      end
    end
end
