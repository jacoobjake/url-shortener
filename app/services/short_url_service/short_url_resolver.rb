module ShortUrlService
  class ShortUrlResolver < ApplicationService
    def initialize(short_code)
      @short_url = ShortUrl.find_by(short_code: short_code)
    end

    def call
      return false if @short_url.nil?

      @short_url
    end
  end
end
