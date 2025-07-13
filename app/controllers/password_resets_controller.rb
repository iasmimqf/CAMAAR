# app/controllers/password_resets_controller.rb
class PasswordResetsController < Devise::PasswordsController
  def edit
    super
  end

  def update
    # --- INÍCIO DOS PUTS DE DEBUG ---
    puts "--- DEBUG: Entrou na ação UPDATE ---"
    puts "PARAMS RECEBIDOS: #{params.inspect}"
    puts "RESET PASSWORD TOKEN DOS PARAMS: #{params[:usuario][:reset_password_token].inspect}"
    # --- FIM DOS PUTS DE DEBUG ---

    self.resource = resource_class.reset_password_by_token(resource_params)

    # --- INÍCIO DOS PUTS DE DEBUG ---
    puts "USUÁRIO ENCONTRADO (resource): #{resource.inspect}"
    puts "ID DO USUÁRIO ENCONTRADO: #{resource.id if resource}"
    puts "USUÁRIO VÁLIDO PELO DEVISE (reset_password_token_valid?): #{resource.reset_password_token_valid? if resource}"
    # --- FIM DOS PUTS DE DEBUG ---

    if resource.errors.empty?
      # --- INÍCIO DOS PUTS DE DEBUG ---
      puts "--- DEBUG: Senha definida com SUCESSO. Sem erros no recurso. ---"
      # --- FIM DOS PUTS DE DEBUG ---
      set_flash_message(:notice, :updated) if is_navigational_format?
      sign_in(resource_name, resource) if sign_in_after_reset_password?
      redirect_to after_resetting_password_path_for(resource)
    else
      # --- INÍCIO DOS PUTS DE DEBUG ---
      puts "--- DEBUG: ERROS NA DEFINIÇÃO DA SENHA ---"
      puts "ERROS COMPLETOS: #{resource.errors.full_messages.inspect}" # ESTA LINHA É CRUCIAL!
      # --- FIM DOS PUTS DE DEBUG ---
      set_flash_message(:alert, :not_updated) if is_navigational_format?
      render :edit
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    new_usuario_session_path
  end

  def resource_params
    params.require(resource_name).permit(:password, :password_confirmation, :reset_password_token)
  end

  def sign_in_after_reset_password?
    Devise.sign_in_after_reset_password
  end
end