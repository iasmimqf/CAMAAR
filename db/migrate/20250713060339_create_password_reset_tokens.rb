class CreatePasswordResetTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :password_reset_tokens do |t|
      # VERIFIQUE E AJUSTE AQUI: Se seu modelo de usuário é 'Usuario', mude :user para :usuario
      t.references :usuario, null: false, foreign_key: true

      t.string :token, null: false, index: { unique: true }
      t.datetime :expires_at, null: false
      t.boolean :used, default: false, null: false

      t.timestamps
    end
  end
end
