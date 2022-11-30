RSpec.shared_examples 'it creates a magic link' do
  it_behaves_like 'display alert', :success

  let(:new_magic_link) { MagicLink.find_by(email:) }

  describe 'new magic link' do
    it 'saves a magic token' do
      expect { subject }.to change(MagicLink, :count).by(1)
    end

    it 'saves an expiration delay on the magic link' do
      subject

      expect(new_magic_link.expires_at).to be_within(10.seconds).of(4.hours.from_now)
    end
  end
end

RSpec.shared_examples 'it sends a magic link for tokens' do
  let(:new_magic_link) { MagicLink.find_by(email:) }

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(TokenMailer, :magic_link)
      .with(new_magic_link)
  end
end

RSpec.shared_examples 'it sends a magic link for signin' do
  let(:new_magic_link) { MagicLink.find_by(email:) }

  it 'sends the email magic link' do
    expect { subject }
      .to have_enqueued_mail(UserMailer, :magic_link_signin)
      .with(new_magic_link)
  end
end

RSpec.shared_examples 'it aborts magic link' do
  it 'does not send the magic link email' do
    expect { subject }.not_to have_enqueued_mail(TokenMailer, :magic_link)
    expect { subject }.not_to have_enqueued_mail(UserMailer, :magic_link_signin)
  end

  it 'does not create a new magic link record' do
    expect { subject }.not_to change(MagicLink, :count)
  end
end
