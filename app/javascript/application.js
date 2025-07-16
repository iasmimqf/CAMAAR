// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "jquery"
import "@nathanvda/cocoon"

// Adicione isto para inicializar o Cocoon
document.addEventListener("turbo:load", function() {
  $(document).on("cocoon:after-insert", function() {
    // Inicialize componentes JS para novas questões aqui
  });
});

require("@rails/ujs").start()
require("jquery")
require("cocoon")