module ShortUrlService
  class ShortUrlRedirector < ApplicationService
    def initialize(short_url)
      @short_url = short_url
    end

    def call
      if @short_url
        redirect_to @short_url.target_url, allow_other_host: true
      else
        render plain: "Short URL not found", status: :not_found
      end
    end

    private

    def capture_redirect
      # Logic to capture the redirect (e.g., logging, analytics)
    end
  end
end
