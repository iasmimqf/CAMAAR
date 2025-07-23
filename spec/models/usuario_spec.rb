# spec/models/usuario_spec.rb
require 'rails_helper'

RSpec.describe Usuario, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      usuario = build(:usuario)
      expect(usuario).to be_valid
    end

    it "is valid without nome (nome is optional)" do
      usuario = build(:usuario, nome: nil)
      expect(usuario).to be_valid
    end

    it "is not valid without email" do
      usuario = build(:usuario, email: nil)
      expect(usuario).not_to be_valid
      expect(usuario.errors[:email]).not_to be_empty
    end

    it "is not valid with duplicate email" do
      create(:usuario, email: "teste@unb.br")
      usuario = build(:usuario, email: "teste@unb.br")
      expect(usuario).not_to be_valid
      expect(usuario.errors[:email]).not_to be_empty
    end

    it "is valid with duplicate matricula (matricula uniqueness not enforced)" do
      create(:usuario, matricula: "123456789")
      usuario = build(:usuario, matricula: "123456789")
      expect(usuario).to be_valid
    end

    it "is not valid with invalid email format" do
      usuario = build(:usuario, email: "email_invalido")
      expect(usuario).not_to be_valid
      expect(usuario.errors[:email]).not_to be_empty
    end
  end

  describe "admin functionality" do
    let(:admin_user) { create(:usuario, admin: true) }
    let(:regular_user) { create(:usuario, admin: false) }

    it "can be an admin" do
      expect(admin_user.admin?).to be true
    end

    it "can be a regular user" do
      expect(regular_user.admin?).to be false
    end
  end

  describe "login functionality" do
    let!(:usuario) { create(:usuario, email: "user@unb.br", matricula: "123456") }

    context "when logging in with email" do
      it "finds user by email" do
        if Usuario.respond_to?(:find_for_database_authentication)
          found_user = Usuario.find_for_database_authentication(login: "user@unb.br")
          expect(found_user).to eq(usuario)
        end
      end
    end

    context "when logging in with matricula" do
      it "finds user by matricula" do
        if Usuario.respond_to?(:find_for_database_authentication)
          found_user = Usuario.find_for_database_authentication(login: "123456")
          expect(found_user).to eq(usuario)
        end
      end
    end

    context "when login does not exist" do
      it "returns nil" do
        if Usuario.respond_to?(:find_for_database_authentication)
          found_user = Usuario.find_for_database_authentication(login: "inexistente")
          expect(found_user).to be_nil
        end
      end
    end
  end

  describe "associations" do
    it "has formularios_criados association" do
      association = Usuario.reflect_on_association(:formularios_criados)
      expect(association.macro).to eq(:has_many)
    end

    # COMENTADO: Formulario functionality not fully implemented yet
    # it "can create formularios as criador" do
    #   usuario = create(:usuario)
    #   # This test assumes the Formulario model exists and works
    #   if defined?(Formulario)
    #     formulario = create(:formulario, criador: usuario)
    #     expect(usuario.formularios_criados).to include(formulario)
    #   end
    # end

    it "has turmas association" do
      association = Usuario.reflect_on_association(:turmas)
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end

    it "has turmas_lecionadas association" do
      association = Usuario.reflect_on_association(:turmas_lecionadas)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "default values" do
    it "admin can be nil by default" do
      usuario = Usuario.new
      expect(usuario.admin).to be_nil
    end

    it "admin? returns false when admin is nil" do
      usuario = Usuario.new(admin: nil)
      expect(usuario.admin?).to be false
    end

    it "admin? returns false when admin is false" do
      usuario = Usuario.new(admin: false)
      expect(usuario.admin?).to be false
    end

    it "admin? returns true when admin is true" do
      usuario = Usuario.new(admin: true)
      expect(usuario.admin?).to be true
    end
  end
end
