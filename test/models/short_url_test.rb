require "test_helper"

class ShortUrlTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    [ :github, :google, :rails_docs ].each do |key|
      assert short_urls(key).valid?, "Expected fixture :#{key} to be valid"
    end
  end

  test "has many short_url_visits" do
    short_url = short_urls(:github)
    assert_respond_to short_url, :short_url_visits
    assert_equal 2, short_url.short_url_visits.count
  end

  test "destroys associated visits when deleted" do
    short_url = short_urls(:github)
    visit_ids = short_url.short_url_visits.pluck(:id)

    short_url.destroy

    visit_ids.each do |id|
      assert_nil ShortUrlVisit.find_by(id: id)
    end
  end

  test "is valid with an https target_url" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "https://example.com")
    assert short_url.valid?
  end

  test "is invalid without a target_url" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: nil)
    assert_not short_url.valid?
    assert_includes short_url.errors[:target_url], "can't be blank"
  end

  test "is invalid with an http target_url" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "http://example.com")
    assert_not short_url.valid?
    assert_includes short_url.errors[:target_url], "must be a valid HTTPS URL"
  end

  test "is invalid with a non-url target_url" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "not-a-url")
    assert_not short_url.valid?
    assert_includes short_url.errors[:target_url], "must be a valid HTTPS URL"
  end

  test "is invalid with an https URL that has no host" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "https://")
    assert_not short_url.valid?
    assert_includes short_url.errors[:target_url], "must be a valid HTTPS URL"
  end

  test "is invalid without a short_code" do
    short_url = ShortUrl.new(short_code: nil, target_url: "https://example.com")
    assert_not short_url.valid?
    assert_includes short_url.errors[:short_code], "can't be blank"
  end

  test "is invalid with a short_code longer than 15 characters" do
    short_url = ShortUrl.new(short_code: "a" * 16, target_url: "https://example.com")
    assert_not short_url.valid?
    assert_includes short_url.errors[:short_code], "is too long (maximum is 15 characters)"
  end

  test "is valid with a short_code of exactly 15 characters" do
    short_url = ShortUrl.new(short_code: "a" * 15, target_url: "https://example.com")
    assert short_url.valid?
  end

  test "is invalid with a duplicate short_code" do
    existing = short_urls(:github)
    short_url = ShortUrl.new(short_code: existing.short_code, target_url: "https://example.com")
    assert_not short_url.valid?
    assert_includes short_url.errors[:short_code], "has already been taken"
  end

  test "is valid when metadata is nil" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "https://example.com", metadata: nil)
    assert short_url.valid?
  end

  test "is valid when metadata is a hash" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "https://example.com", metadata: { title: "Test" })
    assert short_url.valid?
  end

  test "is invalid when metadata is not a hash" do
    short_url = ShortUrl.new(short_code: "abc12345", target_url: "https://example.com")
    short_url.metadata = "not a hash"
    assert_not short_url.valid?
    assert_includes short_url.errors[:metadata], "must be a valid JSON object"
  end
end
