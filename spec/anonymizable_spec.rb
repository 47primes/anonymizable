require 'spec_helper'

describe Anonymizable do

  describe "anonymizable" do

    it "should define a private instance method named anonymize!" do
      expect(Post.private_instance_methods(false)).to include(:anonymize!)
      expect(Comment.private_instance_methods(false)).to include(:anonymize!)
      expect(Like.private_instance_methods(false)).to include(:anonymize!)
    end

    it "should make anonymize! public if specified" do
      expect(User.public_instance_methods(false)).to include(:anonymize!)
    end

  end

  describe "anonymize!" do

    it "should be short-circuited by guard" do
      admin = FactoryGirl.create(:admin)

      expect(admin.anonymize!).to eq(false)
    end

    it "should nullify all attributes named" do
      user = FactoryGirl.create(:user, first_name: "Joe", last_name: "user", profile: "I am a user")

      expect(user.anonymize!).to eq(true)

      user.reload

      expect(user.first_name).to be_nil
      expect(user.last_name).to be_nil
      expect(user.profile).to be_nil
    end

    it "should roll back the transaction if anonymization fails" do
      class Admin < User
        anonymizable do
          attributes :role_id
          public
        end
      end

      user = Admin.create!  first_name: "Admin", 
                            last_name: "User", 
                            profile: "I am an admin. Kinda.",
                            email: "admin@anonymizable.io",
                            role: FactoryGirl.create(:role),
                            password: "foobar"


      expect { user.anonymize! }.to raise_error(ActiveRecord::StatementInvalid)

      user.reload

      expect(user.first_name).to eq("Admin")
      expect(user.last_name).to eq("User")
      expect(user.profile).to eq("I am an admin. Kinda.")
      expect(user.email).to eq("admin@anonymizable.io")
      expect(user.role.user?).to eq(true)
      expect(user.password).to eq("foobar")
    end

    it "should anonymize attributes by proc" do
      user = FactoryGirl.create(:user)
      user.anonymize!

      expect(user.email).to eq("anonymized.user.#{user.id}@anonymizable.io")
    end

    it "should anonymize by method call" do
      user = FactoryGirl.create(:user)
      password = user.password
      expect(user).to receive(:random_password).and_call_original

      user.anonymize!

      expect(user.password == password).to eq(false)
    end

    it "should call anonymize! on specified associations" do
      user = FactoryGirl.create(:user)
      post = FactoryGirl.create(:post, user: user)
      comment = FactoryGirl.create(:comment, post: post, user: user)

      expect_any_instance_of(Post).to receive(:anonymize!).and_call_original
      expect_any_instance_of(Comment).to receive(:anonymize!).and_call_original

      user.anonymize!

      post.reload
      comment.reload

      expect(post.user_id).to be_nil
      expect(comment.user_id).to be_nil
    end

    it "should destroy specified associations" do
      user = FactoryGirl.create(:user)
      image = FactoryGirl.create(:image, user: user)

      expect_any_instance_of(Image).to receive(:destroy).and_call_original

      user.anonymize!
      
      expect(user.images(true).count).to eq(0)
    end

    it "should delete specified associations" do
      avatar = FactoryGirl.create(:avatar)
      user = avatar.user

      expect_any_instance_of(Avatar).to receive(:delete).and_call_original

      user.anonymize!

      expect(user.avatar(true)).to be_nil
    end

    it "should fail if the specified association is not defined on the model" do
      class Customer < User
        anonymizable do
          associations do
            anonymize :shopping_cart
          end
          public
        end
      end

      user = Customer.create! email: "customer@anonymizable.io", password: "foobar",
                              role: FactoryGirl.create(:role)

      expect { user.anonymize! }.to raise_error(NoMethodError)
    end

    it "should fail if after callback is not defined" do
      class Person < User
        anonymizable do
          after :foo
          public
        end
      end

      user = Person.create! email: "person@anonymizable.io", password: "foobar",
                            role: FactoryGirl.create(:role)

      expect { user.anonymize! }.to raise_error(NoMethodError)
    end

    it "should fail if after callback method doesn't receive the correct number of arguments" do
      class Person < User
        anonymizable do
          after :foo
          public
        end

        def foo
        end
      end

      user = Person.create! email: "person@anonymizable.io", password: "foobar",
                            role: FactoryGirl.create(:role)

      expect { user.anonymize! }.to raise_error(ArgumentError)
    end

    it "should not rollback the transaction if a failure occurs in an after callback" do
      class Employee < User
        anonymizable do
          attributes  :first_name, :last_name, :profile,
                      email: Proc.new {|c| "anonymized.user.#{c.id}@anonymizable.io" }, 
                      password: :random_password

          after Proc.new { raise "failure!" }

          public
        end
      end

      user = Employee.create! first_name: "John", last_name: "Doe", profile: "Hello world",
                              email: "employee@anonymizable.io", password: "foobar",
                              role: FactoryGirl.create(:role)

      expect { user.anonymize! }.to raise_error(RuntimeError, "failure!")

      user.reload

      expect(user.first_name).to be_nil
      expect(user.last_name).to be_nil
      expect(user.profile).to be_nil
      expect(user.email).to eq("anonymized.user.#{user.id}@anonymizable.io")
      expect(user.password != "foobar").to eq(true)
    end
  end

end