require 'rails_helper'

RSpec.describe 'show token from magic link', app: :api_particulier do
  subject do
    visit api_particulier_token_show_magic_link_path(access_token: magic_token)
  end

  let!(:user) { create(:user, :with_token, tokens_amount: 2, email:) }
  let(:email) { 'any-email@data.gouv.fr' }

  context 'when the magic link token does not exist' do
    let(:magic_token) { 'wrong-token' }

    it_behaves_like 'display alert', :error

    it 'redirects to the login page' do
      subject

      expect(page).to have_current_path(login_path)
    end
  end

  context 'when the magic link token exists' do
    let!(:magic_link) { create(:magic_link, email:) }
    let(:magic_token) { magic_link.access_token }
    let(:tokens) { magic_link.tokens_from_email }

    context 'when the magic token is still active' do
      it 'has the right number of tokens' do
        expect(tokens.count).to eq(2)
      end

      it 'shows the tokens details' do
        subject

        tokens.each do |token|
          expect(page).to have_css("input[value='#{token.rehash}']")
        end
      end

      it 'has a button to copy the tokens hashes' do
        subject

        tokens.each do |token|
          expect(page).to have_css("##{dom_id(token, :copy_button)}")
        end
      end
    end

    context 'when the magic link token has expired' do
      before { Timecop.freeze(24.hours.from_now) }

      after { Timecop.return }

      it_behaves_like 'display alert', :error

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
