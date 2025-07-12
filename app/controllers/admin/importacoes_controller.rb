# app/controllers/admin/importacoes_controller.rb
module Admin
  class ImportacoesController < Admin::BaseController
    def importar_turmas
      if params[:arquivo].present?
        # Processing logic here
        flash[:notice] = "Arquivo de turmas recebido. O processamento foi iniciado."
        redirect_to admin_turmas_path
      else
        flash[:alert] = "Por favor, selecione um arquivo"
        render :new
      end
    end
  end
end