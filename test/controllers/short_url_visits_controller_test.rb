require "test_helper"

class ShortUrlVisitsControllerTest < ActionDispatch::IntegrationTest
  test "returns JSON with visits and pagination for a known short_code" do
    short_url = short_urls(:github)
    get short_url_visits_url(short_url.short_code)
    assert_response :success

    body = response.parsed_body
    assert body.key?("items")
    assert body.key?("pagination")
    assert_equal 2, body["pagination"]["total"]
  end

  test "items are ordered by created_at descending" do
    short_url = short_urls(:github)
    get short_url_visits_url(short_url.short_code)

    items = response.parsed_body["items"]
    dates = items.map { |i| Time.parse(i["created_at"]) }
    assert_equal dates.sort.reverse, dates
  end

  test "respects page_size param" do
    short_url = short_urls(:github) # has 2 visits in fixtures
    get short_url_visits_url(short_url.short_code), params: { page_size: 1 }

    body = response.parsed_body
    assert_equal 1, body["items"].size
    assert_equal 1, body["pagination"]["limit"]
  end

  test "respects page param for pagination" do
    short_url = short_urls(:github) # has 2 visits
    get short_url_visits_url(short_url.short_code), params: { page: 2, page_size: 1 }

    body = response.parsed_body
    assert_equal 1, body["items"].size
    assert_equal 2, body["pagination"]["page"]
  end

  test "clamps page_size to maximum of 100" do
    short_url = short_urls(:github)
    get short_url_visits_url(short_url.short_code), params: { page_size: 9999 }

    body = response.parsed_body
    assert_equal 100, body["pagination"]["limit"]
  end

  test "clamps page_size to minimum of 1" do
    short_url = short_urls(:github)
    get short_url_visits_url(short_url.short_code), params: { page_size: 0 }

    body = response.parsed_body
    assert_equal 1, body["pagination"]["limit"]
  end

  test "clamps page to minimum of 1 for non-positive values" do
    short_url = short_urls(:github)
    get short_url_visits_url(short_url.short_code), params: { page: -5 }

    body = response.parsed_body
    assert_equal 1, body["pagination"]["page"]
  end

  test "response items exclude short_url_id and updated_at" do
    short_url = short_urls(:github)
    get short_url_visits_url(short_url.short_code)

    item = response.parsed_body["items"].first
    assert_not item.key?("short_url_id")
    assert_not item.key?("updated_at")
  end

  # ── Negative cases ────────────────────────────────────────────────────────────

  test "returns 404 JSON for an unknown short_code" do
    get short_url_visits_url("doesnotexist")
    assert_response :not_found

    body = response.parsed_body
    assert_equal "Short URL not found", body["error"]
  end

  test "returns empty items array when short_url has no visits" do
    short_url = short_urls(:rails_docs) # fixture with no visits
    get short_url_visits_url(short_url.short_code)
    assert_response :success

    body = response.parsed_body
    assert_empty body["items"]
    assert_equal 0, body["pagination"]["total"]
  end
end
