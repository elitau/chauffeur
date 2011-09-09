# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_chauffeur_test_app_session',
  :secret      => 'b6b7abfcfe5509cc6de76dd0d8a4448a68e8352184997db0ab3ea9947ba316bef1dbda95a659c68ca995fbf026b303060ac8b3572f7bda84ed265bd9e6c2e311'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
