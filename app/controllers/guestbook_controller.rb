class GuestbookController < ApplicationController
  before_action :assert_logged_in, except: %i[index new create]
  @@page_size = 5
  def index
    @current_page = Integer(params[:page] || 0)
    @page_size = @@page_size
    @entries = GuestbookEntry.order(created_at: :desc).limit(@@page_size).offset(@current_page * @@page_size ).all
  end

  def new
    @entry = GuestbookEntry.new
  end

  def create
    @entry = GuestbookEntry.new(entry_params)
    if @entry.save
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
      params.require(:guestbook_entry).permit(:author, :body, :home_site, :contact, :hide_contact_from_public)
    end

    def assert_logged_in
      if !current_user 
        return redirect_to login_path
      end
    end
end
