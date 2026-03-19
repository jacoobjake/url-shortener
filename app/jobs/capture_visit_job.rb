class CaptureVisitJob < ApplicationJob
  queue_as :default

  def perform(short_url_id, remote_ip, user_agent, referrer)
    ShortUrlService::CaptureVisit.call(
      short_url_id,
      remote_ip,
      user_agent,
      referrer
    )
  end
end
