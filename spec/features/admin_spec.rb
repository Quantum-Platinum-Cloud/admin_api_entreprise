require 'rails_helper'

RSpec.describe 'admin page', type: :feature do
  let(:admin) { create(:user, :admin) }

  let(:valid_siret) { '13002526500013' }

  let(:mardi_24_aout)   { Time.local(2021,8,24,12,0) }

  let!(:random_user)         { create(:user, context: valid_siret, created_at: mardi_24_aout, updated_at: mardi_24_aout) }
  let!(:confirmed_user)      { create(:user, oauth_api_gouv_id: 12) }
  let!(:unconfirmed_user)    { create(:user, oauth_api_gouv_id: nil) }

  def dom_id(record)
    "#" << [record.class.to_s.underscore, record.id].join('_')
  end

  it_behaves_like 'admin_path', '/admin/users'

  describe 'displays users informations' do
    before do
      login_as(admin)
      visit('/admin/users')
    end

    it 'displays users in a table with one row per user' do
      expect(page.all(".user_summary").size).to eq(User.count)
    end

    it 'email' do
      within(dom_id(random_user)) do
        expect(page).to have_content(random_user.email)
      end
    end

    it 'context' do
      within(dom_id(random_user)) do
        expect(page).to have_content(random_user.context)
      end
    end

    it 'created_at date in a readable fashion' do
      within(dom_id(random_user)) do
        expect(page).to have_content(random_user.created_at.strftime("%d/%m/%Y"))
      end
    end

    it 'confirmed status as Non for unconfirmed user' do
      within(dom_id(unconfirmed_user)) do
        expect(page).to have_content('Non')
      end
    end

    it 'confirmed status as Oui for confirmed user' do
      within(dom_id(confirmed_user)) do
        expect(page).to have_content('Oui')
      end
    end
  end
end
