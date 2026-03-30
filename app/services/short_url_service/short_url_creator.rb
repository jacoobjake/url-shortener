module ShortUrlService
  class ShortUrlCreator < ApplicationService
    def initialize(target_url)
      @short_url = ShortUrl.new(target_url: target_url)
    end

    def call
      @short_url.validate

      if @short_url.errors[:target_url].empty?
        @short_url.metadata = scrape_target(@short_url.target_url)
      else
        return @short_url
      end

      max_retries = 5
      attempts = 0

      loop do
        attempts += 1

        @short_url.short_code = generate_short_code
        @short_url.save!

        break
      rescue ActiveRecord::RecordNotUnique
        if attempts >= max_retries
            Rails.logger.error("Failed to create short URL after #{max_retries} attempts")
            raise
        end
      end
      @short_url
    end

    private

    def scrape_target(url)
      page = MetaInspector.new(url, headers: { "User-Agent" => Rails.configuration.scraping_user_agent })

      {
        title:       page.best_title,
        description: page.best_description,
        og_title:    page.meta_tags["property"]&.dig("og:title")&.first,
        og_image:    page.images.best
      }
    rescue MetaInspector::Error, Faraday::Error, Faraday::ConnectionFailed => e
      Rails.logger.warn("Failed to scrape #{url}: #{e.message}")
      {}
    end

    def generate_short_code
      loop do
        code = SecureRandom.alphanumeric(8)
        break code unless ShortUrl.exists?(short_code: code)
      end
    end
  end
end
