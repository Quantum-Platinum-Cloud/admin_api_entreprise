class JwtApiEntreprise < ApplicationRecord
  belongs_to :user
  has_many :contacts, dependent: :delete_all
  has_and_belongs_to_many :roles

  def rehash
    AccessToken.create(token_payload)
  end

  def access_roles
    self.roles.pluck(:code)
  end

  def user_friendly_exp_date
    "#{Time.zone.at(exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
  end

  def user_and_contacts_email
    Set[*contacts.pluck(:email)] << user.email
  end

  private

  def token_payload
    payload = {
      uid: self.user_id,
      jti: self.id,
      roles: self.roles.pluck(:code),
      sub: self.subject,
      iat: self.iat,
      version: self.version
    }
    # JWT is by design expired if exp is null
    payload[:exp] = self.exp unless self.exp.nil?
    payload
  end
end
