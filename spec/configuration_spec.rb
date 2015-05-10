require 'spec_helper'

describe Anonymizable::Configuration do

  let(:config) { User.anonymization_config }

  describe "only_if" do

    it "can receive the name of the method to guard against anonymization" do
      expect(config.guard).to eq :can_anonymize?
    end

    it "should set the proc to guard against anonymization" do
      proc = Proc.new { true }

      config.only_if proc

      expect(config.guard).to eq proc
    end

    it "should fail if not passed a Proc, String, or Symbol" do
      expect { config.only_if true }.to raise_error(Anonymizable::ConfigurationError, "Expected true to respond to 'call' or be a string or symbol.")
    end

  end

  describe "attributes" do

    it "should set database columns to nullify" do
      expect(config.attrs_to_nullify).to contain_exactly :first_name, :last_name, :profile
    end

    it "should fail if any attribute passed is not defined in the model" do
      expect { config.attributes :middle_name }.to raise_error(Anonymizable::ConfigurationError, "Nonexitent attribute middle_name on User.")
    end

    it "should set proc by which to anonymize model attribute" do
      expect(config.attrs_to_anonymize[:email]).to be_a Proc
    end

    it "should set name of method by which to anonymize model attribute" do
      expect(config.attrs_to_anonymize[:password]).to eq :random_password
    end

  end

  describe "associations" do

    describe "anonymize" do
      it "should set names of associations to anonymize" do
        expect(config.associations_to_anonymize).to contain_exactly :posts, :comments
      end
    end

    describe "delete" do
      it "should set names of associations to delete" do
        expect(config.associations_to_delete).to contain_exactly :avatar
      end
    end

    describe "destroy" do
      it "should set names of associations to destroy" do
        expect(config.associations_to_destroy).to contain_exactly :images
      end
    end    

  end

  describe "after" do

    it "should set name of methods to invoke after anonymization" do
      expect(config.post_anonymization_callbacks.to_a).to eq [:email_user, :email_admin]
    end

    it "should set proc to call after anonymization" do
      proc = Proc.new { "hello" }

      config.after proc

      expect(config.post_anonymization_callbacks.to_a).to eq [:email_user, :email_admin, proc]
    end

  end

  describe "public" do

    it "should set the public flag" do
      expect(config.public?).to eq true
    end

  end

end