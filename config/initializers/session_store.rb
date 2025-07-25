# Caminho: config/initializers/session_store.rb

# Esta é a configuração padrão. Sem opções de 'domain' ou 'tld_length',
# o cookie de sessão será tratado como uma sessão de navegador e não será persistente
# após o fechamento do navegador. Para localhost, ele geralmente funciona
# entre portas enquanto o navegador está aberto.
Rails.application.config.session_store :cookie_store, key: "_camaar_session"
