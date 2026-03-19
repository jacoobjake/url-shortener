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
      html = URI.open(url)
      doc = Nokogiri::HTML(html)

      {
        title:       doc.at("title")&.text&.strip,
        description: doc.at("meta[name='description']")&.[]("content"),
        og_title:    doc.at("meta[property='og:title']")&.[]("content"),
        og_image:    doc.at("meta[property='og:image']")&.[]("content")
      }
    rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Errno::ETIMEDOUT => e
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
