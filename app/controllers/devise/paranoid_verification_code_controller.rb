class Devise::ParanoidVerificationCodeController < DeviseController
  skip_before_filter :handle_paranoid_verification
  prepend_before_filter :authenticate_scope!, :only => [:show, :update]

  def show
    if !resource.nil? && resource.need_paranoid_verification?
      respond_with(resource)
    else
      redirect_to :root
    end
  end

  def update
    if resource.verify_code(resource_params[:paranoid_verification_code])
      warden.session(scope)['paranoid_verify'] = false
      set_flash_message :notice, :updated
      sign_in scope, resource, :bypass => true
      redirect_to stored_location_for(scope) || :root
    else
      respond_with(resource, action: :show)
    end
  end

  private
    def resource_params
      params.require(resource_name).permit(:paranoid_verification_code)
    end

  def scope
    resource_name.to_sym
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!")
    self.resource = send("current_#{resource_name}")
  end
end
