class AttestationsController < AuthenticatedUsersController
  def index
    @jwts = current_user.jwt_api_entreprise

    @best_jwt = best_jwt_to_retrieve_attestations
  end

  def new; end

  def search
    try_search
  rescue SiadeClientError => e
    handle_error!(e)
  end

  private

  def best_jwt_to_retrieve_attestations
    return if @jwts.blank?

    @jwts.max_by { |jwt| JwtFacade.new(jwt_id: jwt.id).attestations_roles }
  end

  def try_search
    @jwt_facade = JwtFacade.new(jwt_id: params[:jwt_id])

    @attestation_facade = EntrepriseWithAttestationsFacade.new(jwt: @jwt_facade.jwt, siret: params[:siret])

    respond_to do |format|
      format.turbo_stream
    end
  end

  def handle_error!(error)
    flash_message(:error, title: 'Erreur lors de la recherche', description: error.message)

    redirect_to attestations_path
  end
end
