require "application_system_test_case"

class ShortUrlsTest < ApplicationSystemTestCase
  # HOME PAGE
  test "visiting the home page shows the shorten form" do
    visit root_url

    assert_selector "h1", text: "Simple URL Shortener"
    assert_selector "#shorten-form"
    assert_button "Create Short URL"
  end

  # CREATING A SHORT URL
  test "submitting a valid URL creates a short URL and shows the details page" do
    visit root_url

    fill_in "short_url[target_url]", with: "https://localhost:19999"
    click_button "submit-shorten"

    # Redirected to show page
    assert_current_path %r{/shorten/[A-Za-z0-9]+}
    assert_selector "h1", text: "Short URL Details"
    assert_selector "input#short-url"
  end

  test "submitting a blank URL shows a validation error" do
    visit root_url

    fill_in "short_url[target_url]", with: ""
    click_button "submit-shorten"

    # Turbo re-renders the form in place without changing the URL
    assert_selector ".error"
    assert_selector "#shorten-form"
  end

  test "submitting an http (non-https) URL shows a validation error" do
    visit root_url

    fill_in "short_url[target_url]", with: "http://example.com"
    click_button "submit-shorten"

    assert_selector ".error"
    assert_selector "#shorten-form"
  end

  # SHOW PAGE
  test "visiting the show page for an existing short URL displays its details" do
    short_url = short_urls(:github)
    visit short_url_show_url(short_url.short_code)

    assert_selector "h1", text: "Short URL Details"
    assert_selector "input#target-url[value='#{short_url.target_url}']"
  end

  test "visiting the show page for an unknown short code displays an alert" do
    visit short_url_show_url("doesnotexist")

    assert_selector "h1", text: "Short URL Details"
    assert_selector ".alert"
  end

  test "clicking Create Another on the show page navigates back to home" do
    short_url = short_urls(:github)
    visit short_url_show_url(short_url.short_code)

    click_on "create-another"

    assert_current_path short_url_index_path
    assert_selector "h1", text: "Simple URL Shortener"
  end

  # SEARCH FORM

  test "searching for a valid short code navigates to the show page" do
    short_url = short_urls(:github)
    visit root_url

    fill_in "search-short-code", with: short_url.short_code
    find("#search-submit").click

    assert_current_path short_url_show_path(short_url.short_code)
    assert_selector "h1", text: "Short URL Details"
  end

  test "show page pre-fills the search input with the current short code" do
    short_url = short_urls(:github)
    visit short_url_show_url(short_url.short_code)

    assert_selector "input#search-short-code[value='#{short_url.short_code}']"
  end

  test "search button is disabled after clearing the search input" do
    visit root_url

    fill_in "search-short-code", with: "somecode"
    fill_in "search-short-code", with: ""

    assert find("#search-submit").disabled?
  end
end
