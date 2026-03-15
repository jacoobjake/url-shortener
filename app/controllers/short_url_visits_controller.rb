class ShortUrlVisitsController < ApplicationController
  before_action :set_short_url

  def index
    page      = [ params.fetch(:page, 1).to_i, 1 ].max
    page_size = [ [ params.fetch(:page_size, 20).to_i, 1 ].max, 100 ].min

    visits = @short_url.short_url_visits
      .order(created_at: :desc)
      .limit(page_size)
      .offset((page - 1) * page_size)

    render json: {
      items: visits.as_json(except: [ :short_url_id, :updated_at ]),
      pagination: {
        total: @short_url.short_url_visits.count,
        limit: page_size,
        page: page
      }
    }
  end

  private

  def set_short_url
    @short_url = ShortUrl.find_by!(short_code: params[:short_code])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Short URL not found" }, status: :not_found
  end
end
