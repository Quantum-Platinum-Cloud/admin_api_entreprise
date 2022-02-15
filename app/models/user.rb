class User < ApplicationRecord
  include RandomToken

  has_many :authorization_requests, dependent: :destroy
  has_many :jwt_api_entreprise, through: :authorization_requests
  has_many :contacts, through: :authorization_requests
  has_many :roles, through: :jwt_api_entreprise

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /#{EMAIL_FORMAT_REGEX}/ }

  scope :added_since_yesterday, -> { where('created_at > ?', 1.day.ago) }

  def self.find_or_initialize_by_email(email)
    insensitive_find_by_email(email) || new(email:)
  end

  def self.insensitive_find_by_email(email)
    where('email ilike (?)', email).limit(1).first
  end

  def confirmed?
    oauth_api_gouv_id.present?
  end

  def demandeur?
    true
  end

  def contact_technique?
    Contact.where(contact_type: 'tech', email:).any?
  end

  def contact_metier?
    Contact.where(contact_type: 'admin', email:).any?
  end

  def full_name
    "#{last_name.try(:upcase)} #{first_name}"
  end

  def tokens_newly_transfered?
    tokens_newly_transfered
  end

  def generate_pwd_renewal_token
    update(pwd_renewal_token: random_token_for(:pwd_renewal_token))
  end

  def any_token_with_attestation_role?
    any_token_with_attestation_sociale_role? || any_token_with_attestation_fiscale_role?
  end

  def any_token_with_attestation_sociale_role?
    tokens_roles_codes.include? 'attestations_sociales'
  end

  def any_token_with_attestation_fiscale_role?
    tokens_roles_codes.include? 'attestations_fiscales'
  end

  private

  def tokens_roles_codes
    jwt_api_entreprise.joins(:roles).pluck('roles.code').uniq
  end
end
