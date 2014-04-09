# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# Enforce the secured secret_token in production environments
if Rails.env.production?
  if Settings.secret_token.blank? || Settings.secret_token == "some 128 char random hex string"
    raise "Secret_token must be specified in settings for production environments!"
  end
  Calcentral::Application.config.secret_token = Settings.secret_token
else
  Calcentral::Application.config.secret_token = Settings.secret_token || SecureRandom.hex(128)
end

# Rails 4 uses secret_key_base
Calcentral::Application.config.secret_key_base = Calcentral::Application.config.secret_token

