require "test_helper"

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest
  test "GET / returns 200" do
    get root_url
    assert_response :success
  end

  test "POST /shorten with valid URL creates record and redirects to show" do
    # Port 19999 is unlikely to be open; connection is refused instantly so no timeout occurs.
    assert_difference "ShortUrl.count", 1 do
      post shorten_url_url, params: { short_url: { target_url: "https://localhost:19999" } }
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "POST /shorten with invalid (http) URL re-renders index with 422" do
    assert_no_difference "ShortUrl.count" do
      post shorten_url_url, params: { short_url: { target_url: "http://example.com" } }
    end
    assert_response :unprocessable_entity
  end

  test "POST /shorten with blank URL re-renders index with 422" do
    assert_no_difference "ShortUrl.count" do
      post shorten_url_url, params: { short_url: { target_url: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "GET /shorten/:short_code returns 200 for existing short_code" do
    get short_url_show_url(short_urls(:github).short_code)
    assert_response :success
  end

  test "GET /shorten/:short_code returns 200 for unknown short_code (shows alert)" do
    get short_url_show_url("doesnotexist")
    assert_response :success
    assert_select ".alert"
  end

  test "GET /:short_code redirects a regular browser to the target URL" do
    short_url = short_urls(:github)
    assert_enqueued_with(job: CaptureVisitJob) do
      get short_url_redirect_url(short_url.short_code)
    end
    assert_redirected_to short_url.target_url
  end

  test "GET /:short_code returns 404 for an unknown short_code" do
    get short_url_redirect_url("doesnotexist")
    assert_response :not_found
  end

  test "GET /:short_code renders crawler_preview for a bot user agent" do
    short_url = short_urls(:github)
    get short_url_redirect_url(short_url.short_code),
      headers: { "User-Agent" => "facebookexternalhit/1.1" }
    assert_response :success
    assert_template "short_urls/crawler_preview"
  end

  test "GET /:short_code does not enqueue CaptureVisitJob for a bot" do
    short_url = short_urls(:github)
    assert_no_enqueued_jobs only: CaptureVisitJob do
      get short_url_redirect_url(short_url.short_code),
        headers: { "User-Agent" => "Twitterbot/1.0" }
    end
  end
end
