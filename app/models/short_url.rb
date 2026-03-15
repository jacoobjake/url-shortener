class ShortUrl < ApplicationRecord
  VALID_URL_REGEX = /\Ahttps:\/\/([a-z0-9\-]+\.)+[a-z]{2,}(:\d+)?(\/[^\s]*)?\z/i

  validates :target_url,
    presence: true,
    format: {
      with: VALID_URL_REGEX,
      message: "must be a valid HTTPS URL with a proper domain (e.g. https://example.com)"
    }
  validates :short_code,
    presence: true,
    length: { maximum: 15 },
    uniqueness: true
  validate :metadata_must_be_a_hash, if: -> { metadata.present? }

  private

  def metadata_must_be_a_hash
    unless metadata.is_a?(Hash)
      errors.add(:metadata, "must be a valid JSON object")
    end
  end
end
