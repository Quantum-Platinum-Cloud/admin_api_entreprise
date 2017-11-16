class UsersController < ApplicationController
  def index
    users = User.all
    render json: users, each_serializer: UserIndexSerializer, status: 200
  end

  def create
    result = User::Create.(params)

    if result.success?
      json_response = result['model']

      result_token = Token::Create.(params, user_id: result['model'].id)
      json_response.merge(
        { error: 'Token creation failed' }) unless result_token.success?

      render json: json_response, status: 201

    else
      errors = result['result.contract.default'].errors.messages
      render json: { errors: errors }, status: 422
    end
  end

  def show
    begin
      user = User.find(params[:id])
      render json: user, serializer: UserShowSerializer, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    end
  end

  def update
    begin
      raise ActionController::ParameterMissing, 'Arguments missing' unless has_updating_params?

      user = User.find(params[:id])
      user.update!(update_params)
      render json: user, status: 200

    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404

    rescue ActiveRecord::RecordInvalid
      render json: { errors: 'Invalid parameters' }, status: 422

    rescue ActionController::ParameterMissing
      render json: {}, status: 400
    end
  end

  def destroy
    begin
      User.destroy(params[:id])
      render json: {}, status: 204
    rescue ActiveRecord::RecordNotFound
      render json: {}, status: 404
    end
  end

  private

  def create_params
    @create_params ||= params.permit(:email, :context, :user_type, contacts: [:email, :phone_number, :contact_type], token_payload: [])
  end

  def all_params_for_create?
    mandatory_params = %i(email context user_type)
    mandatory_params.all? { |e| create_params.has_key? e }
  end

  def update_params
    params.permit :email, :context
  end

  def has_updating_params?
    updating_params = %i(email context)
    updating_params.any? { |p| update_params.has_key? p }
  end
end
