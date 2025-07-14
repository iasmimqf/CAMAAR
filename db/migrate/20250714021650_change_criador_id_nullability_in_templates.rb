# /mnt/c/GitHub/CAMAAR/db/migrate/20250714021650_change_criador_id_nullability_in_templates.rb
# (O nome do arquivo pode variar na data/hora, mas a classe será esta)
class ChangeCriadorIdNullabilityInTemplates < ActiveRecord::Migration[7.1]
  def change
    # Esta linha altera a coluna 'criador_id' na tabela 'templates' para permitir valores nulos.
    # O 'true' significa que agora pode ser NULL.
    # Removi o '-1' que você adicionou, pois não é um valor padrão válido para IDs.
    change_column_null :templates, :criador_id, true
  end
end