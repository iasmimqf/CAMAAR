class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  self.table_name = "jwt_denylist"
end
