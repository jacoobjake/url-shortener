require "test_helper"

class ShortUrlsHelperTest < ActiveSupport::TestCase
  include ShortUrlsHelper

  test "returns true for a standard https URL" do
    assert ShortUrlsHelper.is_valid_url?("https://example.com")
  end

  test "returns true for https URL with path and query" do
    assert ShortUrlsHelper.is_valid_url?("https://example.com/path?query=1&foo=bar")
  end

  test "returns true for https URL with subdomain" do
    assert ShortUrlsHelper.is_valid_url?("https://sub.domain.example.com")
  end

  test "returns false for an http URL" do
    assert_not ShortUrlsHelper.is_valid_url?("http://example.com")
  end

  test "returns false for a blank string" do
    assert_not ShortUrlsHelper.is_valid_url?("")
  end

  test "returns false for a plain domain without scheme" do
    assert_not ShortUrlsHelper.is_valid_url?("example.com")
  end

  test "returns false for ftp scheme" do
    assert_not ShortUrlsHelper.is_valid_url?("ftp://example.com")
  end

  test "returns false for https with no host" do
    assert_not ShortUrlsHelper.is_valid_url?("https://")
  end

  test "returns false for an invalid URI string" do
    assert_not ShortUrlsHelper.is_valid_url?("not a url at all!!")
  end
end
