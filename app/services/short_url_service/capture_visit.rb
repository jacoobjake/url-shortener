module ShortUrlService
  class CaptureVisit < ApplicationService
    def initialize(short_url, request)
      @short_url = short_url
      @request = request
    end

    def call
      create_visit_record
    end

    private

    def anonymize_ip(ip)
      return unless ip

      if ip =~ Resolv::IPv4::Regex
        parts = ip.split(".")
        parts[3] = "0"
        parts.join(".")
      elsif ip =~ Resolv::IPv6::Regex
        parts = ip.split(":")
        parts[3..-1] = [ "0" ] * (parts.length - 3)
        parts.join(":")
      else
        nil
      end
    end

    def create_visit_record
      visit = ShortUrlVisit.new(
        short_url: @short_url,
        ip_address: anonymize_ip(@request.remote_ip),
        user_agent: @request.user_agent,
        referrer: @request.referer
      )
      geo = GeoliteService::GetIpGeolocation.call(@request.remote_ip)

      if geo.present?
        region = geo.dig("subdivisions", 0)
        visit.country_code = geo.dig("country", "iso_code")
        visit.country_name = geo.dig("country", "names", "en")
        visit.region_code = region.dig("iso_code") if region.present?
        visit.region_name = region.dig("names", "en") if region.present?
        visit.city = geo.dig("city", "names", "en")
      end
      visit.save
    end
  end
end
