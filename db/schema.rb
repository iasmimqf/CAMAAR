# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_07_14_010118) do
  create_table "disciplinas", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "nome", null: false
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_disciplinas_on_codigo", unique: true
  end

  create_table "formularios", force: :cascade do |t|
    t.string "titulo"
    t.boolean "ehTemplate"
    t.string "status"
    t.text "estruturaJSON"
    t.datetime "dataDeExpiracao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "criador_id", null: false
    t.integer "template_id"
    t.date "prazo_limite"
    t.string "nome"
    t.index ["criador_id"], name: "index_formularios_on_criador_id"
    t.index ["template_id"], name: "index_formularios_on_template_id"
  end

  create_table "formularios_turmas", id: false, force: :cascade do |t|
    t.integer "formulario_id", null: false
    t.integer "turma_id", null: false
  end

  create_table "questoes", force: :cascade do |t|
    t.text "enunciado", null: false
    t.string "tipo", null: false
    t.boolean "obrigatoria", default: false
    t.string "opcoes"
    t.integer "template_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id", "created_at"], name: "index_questoes_on_template_id_and_created_at"
    t.index ["template_id"], name: "index_questoes_on_template_id"
  end

  create_table "resposta_formularios", force: :cascade do |t|
    t.integer "formulario_id", null: false
    t.integer "respondente_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["formulario_id", "respondente_id"], name: "index_resposta_formularios_on_formulario_id_and_respondente_id", unique: true
    t.index ["formulario_id"], name: "index_resposta_formularios_on_formulario_id"
    t.index ["respondente_id"], name: "index_resposta_formularios_on_respondente_id"
  end

  create_table "resposta_questoes", force: :cascade do |t|
    t.integer "resposta_formulario_id", null: false
    t.integer "questao_id", null: false
    t.integer "valor_resposta"
    t.text "texto_resposta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questao_id"], name: "index_resposta_questoes_on_questao_id"
    t.index ["resposta_formulario_id", "questao_id"], name: "idx_on_resposta_formulario_id_questao_id_44e6e07b0e", unique: true
    t.index ["resposta_formulario_id"], name: "index_resposta_questoes_on_resposta_formulario_id"
  end

  create_table "respostas", force: :cascade do |t|
    t.datetime "dataDeSubmissao"
    t.text "respostasJSON"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "formulario_id", null: false
    t.integer "avaliador_id", null: false
    t.index ["avaliador_id"], name: "index_respostas_on_avaliador_id"
    t.index ["formulario_id"], name: "index_respostas_on_formulario_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "titulo", null: false
    t.integer "criador_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["criador_id"], name: "index_templates_on_criador_id"
    t.index ["titulo"], name: "index_templates_on_titulo", unique: true
  end

  create_table "turmas", force: :cascade do |t|
    t.string "codigo_turma", null: false
    t.string "semestre", null: false
    t.string "horario"
    t.integer "disciplina_id", null: false
    t.integer "professor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disciplina_id", "codigo_turma", "semestre"], name: "index_turmas_on_unique_keys", unique: true
    t.index ["disciplina_id"], name: "index_turmas_on_disciplina_id"
    t.index ["professor_id"], name: "index_turmas_on_professor_id"
  end

  create_table "turmas_usuarios", id: false, force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "turma_id", null: false
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "matricula"
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "formularios", "templates"
  add_foreign_key "formularios", "usuarios", column: "criador_id"
  add_foreign_key "questoes", "templates"
  add_foreign_key "resposta_formularios", "formularios"
  add_foreign_key "resposta_formularios", "usuarios", column: "respondente_id"
  add_foreign_key "resposta_questoes", "questoes", column: "questao_id"
  add_foreign_key "resposta_questoes", "resposta_formularios"
  add_foreign_key "respostas", "formularios"
  add_foreign_key "respostas", "usuarios", column: "avaliador_id"
  add_foreign_key "templates", "usuarios", column: "criador_id"
  add_foreign_key "turmas", "disciplinas"
  add_foreign_key "turmas", "usuarios", column: "professor_id"
end
