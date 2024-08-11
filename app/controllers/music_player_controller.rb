class MusicPlayerController < ApplicationController
    def index
      @tracks = Dir.glob(Rails.root.join('app', 'assets', 'audio', '*.{ogg,mp3,wav}')).map do |file|
        filename = File.basename(file)
        {
          name: filename,
          url: ActionController::Base.helpers.asset_path("#{filename}")
        }
      end
      
      respond_to do |format|
        format.html { render layout: false }
        format.json { render json: @tracks }
      end
    end
  end