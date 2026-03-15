module ShortUrlsHelper
  module_function

  def is_valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
