# Caminho: app/validators/password_complexity_validator.rb

##
# Validador customizado para complexidade de senha.
#
# Descrição: Este validador garante que uma senha atenda a critérios mínimos de
#    complexidade, como comprimento mínimo, presença de letras minúsculas,
#    maiúsculas, dígitos e caracteres especiais. Ele é projetado para ser
#    usado com `ActiveModel::EachValidator`.
class PasswordComplexityValidator < ActiveModel::EachValidator
  ##
  # Valida cada atributo de senha para complexidade.
  #
  # Descrição: Este método é chamado para cada atributo (geralmente `:password`)
  #    que utiliza este validador. Ele verifica se a senha fornecida atende aos
  #    requisitos de comprimento, e se contém pelo menos uma letra minúscula,
  #    uma maiúscula, um dígito e um caractere especial. Adiciona erros ao
  #    registro se algum critério não for atendido.
  # Argumentos:
  #    - `record`: O objeto do modelo que está sendo validado (e.g., `Usuario`).
  #    - `attribute`: O nome do atributo que está sendo validado (e.g., `:password`).
  #    - `value`: O valor do atributo (a senha em si).
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Adiciona mensagens de erro ao objeto `record.errors`
  #    se a senha não atender aos critérios de complexidade.
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :too_short, count: 10) if value.length < 10
    record.errors.add(attribute, :missing_lowercase) unless value =~ /[a-z]/
    record.errors.add(attribute, :missing_uppercase) unless value =~ /[A-Z]/
    record.errors.add(attribute, :missing_digit)     unless value =~ /\d/
    record.errors.add(attribute, :missing_special_character) unless value =~ /[^A-Za-z0-9]/
  end
end
