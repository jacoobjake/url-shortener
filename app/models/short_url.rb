class ShortUrl < ApplicationRecord
  has_many :short_url_visits, dependent: :destroy

  validates :target_url,
    presence: true
  validates :short_code,
    presence: true,
    length: { maximum: 15 },
    uniqueness: true
  validate :target_url_must_be_https, if: -> { target_url.present? }
  validate :metadata_must_be_a_hash, if: -> { metadata.present? }

  private

  def metadata_must_be_a_hash
    unless metadata.is_a?(Hash)
      errors.add(:metadata, "must be a valid JSON object")
    end
  end

  def target_url_must_be_https
    return if ShortUrlsHelper.is_valid_url?(target_url)

    errors.add(:target_url, "must be a valid HTTPS URL")
  end
end
