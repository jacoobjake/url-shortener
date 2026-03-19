require "test_helper"

class ShortUrlService::ShortUrlResolverTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test "returns the ShortUrl for a known short_code" do
    short_url = short_urls(:github)
    result = ShortUrlService::ShortUrlResolver.call(short_url.short_code)
    assert_equal short_url, result
  end

  test "caches the result on subsequent calls" do
    short_url = short_urls(:github)

    # Swap to a real in-memory cache for this test only
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    # Prime the cache with the real DB call
    first_result = ShortUrlService::ShortUrlResolver.call(short_url.short_code)
    assert first_result, "Expected a ShortUrl from DB"

    # Remove the record from DB (delete visits first to avoid FK violation)
    short_url.short_url_visits.delete_all
    ShortUrl.where(short_code: short_url.short_code).delete_all

    # Should still return the cached object without hitting the DB again
    result = ShortUrlService::ShortUrlResolver.call(short_url.short_code)
    assert result, "Expected cached result to survive DB deletion"
    assert_equal short_url.id, result.id
  ensure
    Rails.cache = ActiveSupport::Cache::NullStore.new
  end

  test "returns false for an unknown short_code" do
    result = ShortUrlService::ShortUrlResolver.call("doesnotexist")
    assert_equal false, result
  end

  test "returns false for a nil short_code" do
    result = ShortUrlService::ShortUrlResolver.call(nil)
    assert_equal false, result
  end

  test "returns false for an empty short_code" do
    result = ShortUrlService::ShortUrlResolver.call("")
    assert_equal false, result
  end
end
