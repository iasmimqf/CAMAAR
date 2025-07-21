# app/validators/password_complexity_validator.rb
class PasswordComplexityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :too_short, count: 10) if value.length < 10
    record.errors.add(attribute, :missing_lowercase) unless value =~ /[a-z]/
    record.errors.add(attribute, :missing_uppercase) unless value =~ /[A-Z]/
    record.errors.add(attribute, :missing_digit)     unless value =~ /\d/
    record.errors.add(attribute, :missing_special_character) unless value =~ /[^A-Za-z0-9]/
  end
end
