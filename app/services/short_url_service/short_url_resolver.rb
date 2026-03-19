module ShortUrlService
  class ShortUrlResolver < ApplicationService
    def initialize(short_code)
      @short_url = Rails.cache.fetch("short_url/#{short_code}", expires_in: 12.hours) do
        ShortUrl.find_by(short_code: short_code)
      end
    end

    def call
      return false if @short_url.nil?

      @short_url
    end
  end
end
