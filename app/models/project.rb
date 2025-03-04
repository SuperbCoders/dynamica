class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: :slugged

  # @return [User] who created this project
  belongs_to :user

  has_many :permissions, dependent: :destroy
  has_many :pending_permissions, dependent: :destroy
  has_many :users, through: :permissions

  has_many :items, dependent: :destroy
  has_many :forecasts, dependent: :destroy

  has_many :logs, dependent: :destroy

  has_one :shopify_integration, dependent: :destroy, class_name: 'ThirdParty::Shopify::Integration'

  validates :user, presence: true
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[-_A-Za-z0-9]+\z/ }

  before_validation :set_default_values

  # Marks project as a project that uses API
  def api_used!
    update_column(:api_used, true) unless api_used?
  end

  def recent_forecast
    forecasts.order(created_at: :asc, finished_at: :asc).last
  end

  # @return [Boolean] whether this project is integrated with Shopify
  def shopify?
    shopify_integration.present?
  end

  private

    def self.generate_unique_slug
      loop do
        slug = SecureRandom.hex(16)
        break slug unless self.exists?(slug: slug)
      end
    end

    def self.generate_unique_slug_by_name(name)
      derived_slug = name.to_s.parameterize
      if derived_slug.present? &&
        !friendly_id_config.reserved_words.include?(derived_slug) &&
        !Project.exists?(slug: derived_slug)
        derived_slug
      else
        Project.generate_unique_slug
      end
    end

    def set_default_values
      if slug.blank?
        self.slug = Project.generate_unique_slug_by_name(name)
      end
    end
end
