# Caminho: app/models/password_reset_token.rb

##
# Representa um token de redefinição de senha.
#
# Descrição: Este modelo é usado para gerenciar tokens temporários que permitem
#    aos usuários redefinir suas senhas. Cada token está associado a um usuário,
#    possui uma data de expiração e um status que indica se já foi utilizado.
class PasswordResetToken < ApplicationRecord
  # VERIFIQUE E AJUSTE AQUI: Se seu modelo de usuário é 'Usuario', mude :user para :usuario
  ##
  # Associação: Pertence a um `Usuario`.
  #
  # Descrição: Define a relação onde cada `PasswordResetToken` está vinculado a
  #    um `Usuario` específico.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Usuario` ao qual este token pertence.
  # Efeitos colaterais: Define um método `usuario` e `usuario=` para gerenciar a associação.
  belongs_to :usuario

  ##
  # Validação: Garante a presença e unicidade do `token`.
  #
  # Descrição: Assegura que cada token de redefinição de senha seja único e
  #    esteja presente, garantindo a integridade e segurança do token.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `token` estiver ausente ou não for único.
  validates :token, presence: true, uniqueness: true

  ##
  # Validação: Garante a presença do `expires_at`.
  #
  # Descrição: Assegura que cada token de redefinição de senha tenha uma data
  #    de expiração definida, o que é crucial para a segurança.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `expires_at` estiver ausente.
  validates :expires_at, presence: true

  ##
  # Validação: Garante que o atributo `used` seja um booleano.
  #
  # Descrição: Assegura que o status `used` (utilizado) do token seja um valor
  #    booleano (`true` ou `false`), indicando se o token já foi consumido.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `used` não for `true` ou `false`.
  validates :used, inclusion: { in: [ true, false ] }

  ##
  # Verifica se o token expirou.
  #
  # Descrição: Compara a data de expiração do token (`expires_at`) com a hora
  #    atual para determinar se o token ainda é válido ou se já expirou.
  # Argumentos: Nenhum.
  # Retorno: `true` se a data de expiração for anterior à hora atual, `false` caso contrário.
  # Efeitos colaterais: Nenhum.
  def expired?
    expires_at < Time.current
  end

  ##
  # Verifica se o token já foi utilizado.
  #
  # Descrição: Retorna o valor do atributo `used`, que indica se o token
  #    já foi consumido para redefinir uma senha.
  # Argumentos: Nenhum.
  # Retorno: `true` se o token foi utilizado, `false` caso contrário.
  # Efeitos colaterais: Nenhum.
  def used?
    used
  end

  ##
  # Invalida o token, marcando-o como utilizado.
  #
  # Descrição: Atualiza o atributo `used` do token para `true`, tornando-o
  #    inválido para futuras tentativas de redefinição de senha.
  # Argumentos: Nenhum.
  # Retorno: `true` se a atualização for bem-sucedida, `false` caso contrário.
  # Efeitos colaterais: Altera o registro do token no banco de dados, marcando-o como usado.
  def invalidate!
    update!(used: true)
  end
end
