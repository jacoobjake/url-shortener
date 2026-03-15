class ShortUrlsController < ApplicationController
  def index
    @short_url = ShortUrl.new
  end

  def create
    @short_url = ShortUrlService::ShortUrlCreator.call(short_url_params[:target_url])

    if @short_url.persisted?
      redirect_to shorten_url_show_path(@short_url)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @short_url = ShortUrl.where(short_code: params[:short_code]).first
  end

  def redirect
      # TODO: Add support to capture traffic and analytics
      # TODO: Implement short url caching
      @short_url = ShortUrl.find_by(short_code: params[:short_code])
      if @short_url
        redirect_to @short_url.target_url, allow_other_host: true
      else
        render plain: "Short URL not found", status: :not_found
      end
  end

  private
    def short_url_params
      params.require(:short_url).permit(:short_code, :target_url)
    end
end
