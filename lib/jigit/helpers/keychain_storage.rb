require "keychain"

module Jigit
  class KeychainStorage
    def initialize(keychain = nil)
      @keychain = keychain ? keychain : Keychain.default
    end

    def save(account, password, service)
      @keychain.generic_passwords.create(service: service, account: account, password: password)
    rescue Keychain::DuplicateItemError => e
      puts "Duplicated item in keychain storage: #{e.message}"
    end

    def load_item(service)
      @keychain.generic_passwords.where(service: service).first
    end
  end
end
