require "spec_helper"

describe TypedStoreAccessor do
  class MyTestClass
    include TypedStoreAccessor

    def read_attribute(attr)
      self.send(attr)
    end

    def write_attribute(attr, value)
      self.send("#{attr}=", value)
    end

    private :read_attribute, :write_attribute

    typed_store_accessor :settings, :boolean, :test_thing
    typed_store_accessor :settings, :boolean, :test_thing_default, true
    typed_store_accessor :settings, :non_blank_string, :string_thing
    typed_store_accessor :settings,
                         :restricted_string,
                         :restricted_string_thing,
                         "default",
                         values: ["defined_value", "default"]
    typed_store_accessor :settings, :array, :array_thing
    typed_store_accessor :settings, :float, :float_thing
    typed_store_accessor :settings, :big_decimal, :big_decimal_thing
    typed_store_accessor :settings, :hash, :hash_thing
    typed_store_accessor :settings, :hash, :hash_with_default, {}

    def settings
      @settings ||= {}
    end
  end

  describe ".typed_store_accessor" do
    subject { MyTestClass.new }

    it "generates a getter" do
      expect(subject.test_thing).to be_nil
    end

    it "generates a setter" do
      subject.test_thing = true
      expect(subject.test_thing).to eq true
    end

    describe ":boolean type" do
      it "converts '0' to false" do
        subject.test_thing = "0"
        expect(subject.test_thing).to eq false
      end

      it "converts '1' to true" do
        subject.test_thing = "1"
        expect(subject.test_thing).to eq true
      end

      it "leaves true alone" do
        subject.test_thing = true
        expect(subject.test_thing).to eq true
      end

      it "leaves false alone" do
        subject.test_thing = false
        expect(subject.test_thing).to eq false
      end

      it "leaves nil alone" do
        subject.test_thing = nil
        expect(subject.test_thing).to be_nil
      end

      it "creates an eh? method" do
        subject.test_thing = true
        expect(subject.test_thing?).to eq true
      end
    end

    describe "with default" do
      it "defaults to the default" do
        expect(subject.test_thing_default).to eq(true)
      end

      it "Can be overridden with a value" do
        subject.test_thing_default = false
        expect(subject.test_thing_default).to eq(false)
      end

      it "can be reverted to the default" do
        subject.test_thing_default = false
        expect(subject.test_thing_default).to eq(false)
        subject.test_thing_default = nil
        expect(subject.test_thing_default).to eq(true)
      end
    end

    describe "non_blank_string type" do
      it "saves a string" do
        subject.string_thing = "blibbety"
        expect(subject.string_thing).to eql "blibbety"
      end
      it "saves nil as nil" do
        subject.string_thing = nil
        expect(subject.string_thing).to be_nil
      end

      it "saves '' as nil" do
        subject.string_thing = ""
        expect(subject.string_thing).to be_nil
      end
    end

    describe "restricted_string type" do
      it "saves a string from given values" do
        subject.restricted_string_thing = "defined_value"
        expect(subject.restricted_string_thing).to eq("defined_value")
      end

      it "gives the default" do
        expect(subject.restricted_string_thing).to eq("default")
      end

      it "raises an error if string is not in defined array" do
        expect { subject.restricted_string_thing = "something not defined" }
          .to raise_error("Value not one of the following: defined_value default")
      end

      it "raises an error when setting if no values are given" do
        class TestClassWithoutValues
          include TypedStoreAccessor
          def read_attribute(attr)
            self.send(attr)
          end

          def write_attribute(attr, value)
            self.send("#{attr}=", value)
          end


          typed_store_accessor :settings,
                               :restricted_string,
                               :restricted_string_thing,
                               "default"
          def settings
            @settings ||= {}
          end
        end
        subject = TestClassWithoutValues.new
        expect { subject.restricted_string_thing = "blah" }
          .to raise_error("no values provided")
      end

      it "it returns nil if no default is given" do
        class OtherTestClassWithoutValues
          include TypedStoreAccessor
          def read_attribute(attr)
            self.send(attr)
          end

          def write_attribute(attr, value)
            self.send("#{attr}=", value)
          end


          typed_store_accessor :settings,
                               :restricted_string,
                               :restricted_string_thing
          def settings
            @settings ||= {}
          end
        end
        subject = OtherTestClassWithoutValues.new
        expect(subject.restricted_string_thing).to be(nil)
      end
    end

    describe "hash type" do
      it "gets" do
        expect(subject.hash_thing).to eq(nil)
      end

      it "sets" do
        subject.hash_thing = { ima: "hash" }
        expect(subject.hash_thing).to eq(ima: "hash")
      end

      it "sets a default" do
        expect(subject.hash_with_default).to eq({})
      end

      it "dupes the default to not share an object" do
        subject.hash_with_default["shared"]=false
        expect(MyTestClass.new.hash_with_default).to eq({})
      end

      it "raises an error if not set to hash type" do
        expect { subject.hash_thing = "Ima string" }
          .to raise_error("Value is not a hash")
      end

      it "returns nil if no default is given" do
        expect(subject.hash_thing).to eq(nil)
      end
    end

    describe "array type" do
      it "defaults to an empty array, not nil" do
        expect(subject.array_thing). to eql []
      end

      it "saves an array" do
        subject.array_thing = %w(your mom)
        expect(subject.array_thing).to eql %w(your mom)
      end

      it "handles a nil" do
        subject.array_thing = [1]
        subject.array_thing = nil
        expect(subject.array_thing).to eql []
      end

      it "type checks that it is an array" do
        expect {
          subject.array_thing = "asdf"
        }.to raise_error(RuntimeError)
      end
    end

    describe "float type" do
      it "defaults to nil" do
        expect(subject.float_thing).to be_nil
      end

      it "saves a float" do
        subject.float_thing = 1.2
        expect(subject.float_thing).to eq 1.2
      end

      it "converts integer to float" do
        subject.float_thing = 1
        expect(subject.float_thing).to eq 1.0
      end
    end

    describe "big_decimal type" do
      it "defaults to nil" do
        expect(subject.big_decimal_thing).to be_nil
      end

      it "saves a big_decimal" do
        subject.big_decimal_thing = 1.2
        expect(subject.big_decimal_thing).to eq 1.2
      end

      it "converts integer to big_decimal" do
        subject.big_decimal_thing = 1
        expect(subject.big_decimal_thing).to eq 1.0
      end
    end

    it "generates an exception with an unknown type" do
      class MyTestClass
        typed_store_accessor :settings, :unkown_type, :foobar
      end

      x = MyTestClass.new
      expect {
        x.foobar = "wharrrrrrgarbl"
      }.to raise_error(RuntimeError)
    end

    it "allows the generated methods to be overridden" do
      class MyOtherTestClass
        include TypedStoreAccessor

        def read_attribute(attr)
          self.send(attr)
        end

        def write_attribute(attr, value)
          self.send("#{attr}=", value)
        end

        typed_store_accessor :settings, :boolean, :override_me

        def settings
          @settings ||= { "override_me" => true }
        end

        def override_me
          "super returned #{super}"
        end
      end

      expect(MyOtherTestClass.new.override_me).to eql "super returned true"
    end
  end
end
