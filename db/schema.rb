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

ActiveRecord::Schema[8.0].define(version: 2025_07_09_131421) do
  create_table "formularios", force: :cascade do |t|
    t.string "titulo"
    t.boolean "ehTemplate"
    t.string "status"
    t.text "estruturaJSON"
    t.datetime "dataDeExpiracao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "criador_id", null: false
    t.index ["criador_id"], name: "index_formularios_on_criador_id"
  end

  create_table "formularios_turmas", id: false, force: :cascade do |t|
    t.integer "formulario_id", null: false
    t.integer "turma_id", null: false
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

  create_table "turmas", force: :cascade do |t|
    t.string "nomeDaTurma"
    t.string "semestre"
    t.boolean "ativo"
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "professor_id", null: false
    t.index ["professor_id"], name: "index_turmas_on_professor_id"
  end

  create_table "turmas_usuarios", id: false, force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "turma_id", null: false
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "matricula"
    t.string "nome"
    t.string "perfil"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "formularios", "usuarios", column: "criador_id"
  add_foreign_key "respostas", "formularios"
  add_foreign_key "respostas", "usuarios", column: "avaliador_id"
  add_foreign_key "turmas", "usuarios", column: "professor_id"
end
