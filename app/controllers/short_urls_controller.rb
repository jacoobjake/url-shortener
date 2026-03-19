class ShortUrlsController < ApplicationController
  rate_limit to: 5,
    within: 1.minutes,
    by: -> { request.remote_ip },
    only: :create,
    with: :rate_limited,
    name: "create"
  rate_limit to: 100,
    within: 1.minutes,
    by: -> { "#{params[:short_code]}:#{request.remote_ip}" },
    only: :redirect,
    with: :rate_limited,
    name: "redirect"
  rate_limit to: 300,
    within: 1.minutes,
    by: -> { request.remote_ip },
    except: [ :create, :redirect ],
    with: :rate_limited,
    name: "general"
  def index
    @short_url = ShortUrl.new
  end

  def create
    @short_url = ShortUrlService::ShortUrlCreator.call(short_url_params[:target_url])

    if @short_url.persisted?
      redirect_to short_url_show_path(@short_url[:short_code])
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @short_url = ShortUrl.find_by(short_code: params[:short_code])
  end

  def redirect
    short_url = ShortUrlService::ShortUrlResolver.call(params[:short_code])

    unless short_url && ShortUrlsHelper.is_valid_url?(short_url.target_url)
      return render file: "public/404.html", layout: false, status: :not_found
    end

    if crawler_request?
      render :crawler_preview, locals: { short_url: short_url }, layout: "application"
    else
      CaptureVisitJob.perform_later(short_url.id, request.remote_ip, request.user_agent, request.referer, Time.current)
      redirect_to short_url.target_url, allow_other_host: true
    end
  end

  private

  def crawler_request?
    Rails.logger.debug "User Agent: #{request.user_agent}"
    crawler_agents = /facebookexternalhit|twitterbot|linkedinbot|slackbot|discordbot|telegrambot|whatsapp|googlebot|bingbot|applebot|pinterest|embedly/i
    crawler_agents.match?(request.user_agent.to_s)
  end

  def short_url_params
    params.require(:short_url).permit(:short_code, :target_url)
  end

  def rate_limited
    head :too_many_requests
  end
end
