require "jigit/helpers/keychain_storage"

describe Jigit::KeychainStorage do
  before(:each) do
    @keychain = Keychain.create(File.join(Dir.tmpdir, "keychain_storage_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), "pass")
  end

  after(:each) do
    @keychain.delete
  end

  describe "keychain" do
    let(:service) { "myhost" }
    let(:account) { "admin" }
    let(:password) { "123456" }
    let(:keychain_storage) { Jigit::KeychainStorage.new(@keychain) }

    context("when stores a new item") do
      it "makes the stored item be available to load" do
        keychain_storage.save(account, password, service)
        item = keychain_storage.load_item(service)
        expect(item.password).to be == password
        expect(item.account).to be == account
        expect(item.service).to be == service
      end
    end

    context("when stores a duplicated item") do
      it "doesn't raise an exception" do
        keychain_storage.save(account, password, service)
        expect { keychain_storage.save(account, password, service) }.to_not raise_error
      end
    end
  end
end
