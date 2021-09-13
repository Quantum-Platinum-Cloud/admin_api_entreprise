class DatapassWebhook
  include ::Interactor::Organizer

  organize ::DatapassWebhook::FindOrCreateUser,
           ::DatapassWebhook::FindOrCreateAuthorizationRequest,
           ::DatapassWebhook::CreateJwtToken,
           ::DatapassWebhook::UpdateMailjetContacts,
           ::DatapassWebhook::ExtractMailjetVariables,
           ::DatapassWebhook::ScheduleAuthorizationRequestEmails
end
