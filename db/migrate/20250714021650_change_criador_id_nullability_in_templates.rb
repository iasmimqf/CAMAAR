# db/migrate/XXXXXX_change_criador_id_nullability_in_templates.rb
class ChangeCriadorIdNullabilityInTemplates < ActiveRecord::Migration[7.1]
  def change
    change_column_null :templates, :criador_id, true, -1 # Substitua '0' por um valor padrão se desejar, mas 'true' é o mais importante
  end
end