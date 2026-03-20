require "test_helper"

class ShortUrlVisitTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    [ :us_visit, :uk_visit, :no_geo_visit ].each do |key|
      assert short_url_visits(key).valid?, "Expected fixture :#{key} to be valid"
    end
  end

  test "belongs to a short_url" do
    visit = short_url_visits(:us_visit)
    assert_respond_to visit, :short_url
    assert_equal short_urls(:github), visit.short_url
  end

  test "is invalid without a short_url" do
    visit = ShortUrlVisit.new(visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:short_url], "must exist"
  end

  test "is invalid without a visited_at" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github))
    assert_not visit.valid?
    assert_includes visit.errors[:visited_at], "can't be blank"
  end

  test "is valid with a nil country_code" do
    visit = short_url_visits(:no_geo_visit)
    assert_nil visit.country_code
    assert visit.valid?
  end

  test "is valid with a 2-character country_code" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), country_code: "US", visited_at: Time.current)
    assert visit.valid?
  end

  test "is invalid with a country_code not equal to 2 characters" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), country_code: "USA", visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:country_code], "is the wrong length (should be 2 characters)"
  end

  test "is invalid with a 1-character country_code" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), country_code: "U", visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:country_code], "is the wrong length (should be 2 characters)"
  end

  test "is valid with a nil region_code" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), region_code: nil, visited_at: Time.current)
    assert visit.valid?
  end

  test "is valid with a region_code up to 10 characters" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), region_code: "CA", visited_at: Time.current)
    assert visit.valid?
  end

  test "is invalid with a region_code longer than 10 characters" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), region_code: "A" * 11, visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:region_code], "is too long (maximum is 10 characters)"
  end

  test "is invalid with a country_name longer than 100 characters" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), country_name: "A" * 101, visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:country_name], "is too long (maximum is 100 characters)"
  end

  test "is invalid with a region_name longer than 100 characters" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), region_name: "A" * 101, visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:region_name], "is too long (maximum is 100 characters)"
  end

  test "is invalid with a city longer than 100 characters" do
    visit = ShortUrlVisit.new(short_url: short_urls(:github), city: "A" * 101, visited_at: Time.current)
    assert_not visit.valid?
    assert_includes visit.errors[:city], "is too long (maximum is 100 characters)"
  end

  test "is valid with all geo fields nil" do
    visit = ShortUrlVisit.new(
      short_url: short_urls(:github),
      country_code: nil, country_name: nil,
      region_code: nil, region_name: nil,
      city: nil, visited_at: Time.current
    )
    assert visit.valid?
  end
end
