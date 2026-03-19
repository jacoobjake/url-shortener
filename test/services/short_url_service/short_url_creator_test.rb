require "test_helper"

class ShortUrlService::ShortUrlCreatorTest < ActiveSupport::TestCase
  test "creates a persisted ShortUrl when network is unreachable (empty metadata fallback)" do
    # Port 19999 is refused instantly; the creator rescues and stores {} metadata
    result = ShortUrlService::ShortUrlCreator.call("https://localhost:19999")
    assert result.persisted?
    assert_equal "https://localhost:19999", result.target_url
    assert_equal({}, result.metadata)
  end

  test "generates an 8-character alphanumeric short_code" do
    result = ShortUrlService::ShortUrlCreator.call("https://localhost:19999")
    assert_match(/\A[a-zA-Z0-9]{8}\z/, result.short_code)
  end

  test "short_code is unique across multiple creations" do
    a = ShortUrlService::ShortUrlCreator.call("https://localhost:19999")
    b = ShortUrlService::ShortUrlCreator.call("https://localhost:19999")
    assert_not_equal a.short_code, b.short_code
  end

  test "stores metadata hash when scraping succeeds" do
    html = "<html><head><title>Hello</title><meta name='description' content='Desc'></head></html>"

    # Override the private scrape_target on the instance to avoid real HTTP
    creator = ShortUrlService::ShortUrlCreator.new("https://example.com")
    creator.define_singleton_method(:scrape_target) do |_url|
      doc = Nokogiri::HTML(html)
      {
        title:       doc.at("title")&.text&.strip,
        description: doc.at("meta[name='description']")&.[]("content"),
        og_title:    doc.at("meta[property='og:title']")&.[]("content"),
        og_image:    doc.at("meta[property='og:image']")&.[]("content")
      }
    end

    result = creator.call
    assert result.persisted?
    assert_equal "Hello", result.metadata["title"]
    assert_equal "Desc",  result.metadata["description"]
  end

  test "returns an unpersisted ShortUrl for an http URL" do
    result = ShortUrlService::ShortUrlCreator.call("http://example.com")
    assert_not result.persisted?
    assert_includes result.errors[:target_url], "must be a valid HTTPS URL"
  end

  test "returns an unpersisted ShortUrl for a blank URL" do
    result = ShortUrlService::ShortUrlCreator.call("")
    assert_not result.persisted?
    assert result.errors[:target_url].any?
  end

  test "returns an unpersisted ShortUrl for a nil URL" do
    result = ShortUrlService::ShortUrlCreator.call(nil)
    assert_not result.persisted?
    assert result.errors[:target_url].any?
  end
end
