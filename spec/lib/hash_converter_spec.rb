describe HashConverter do

  context "hash conversion" do
    it "should convert a symbol-keyed hash to camelcase" do
      HashConverter.camelize(
        {
          foo_bar_baz: {
            some_sub_hash: {
              a_sub_sub_hash: {
                foo_val: 'abc',
                another_value: 'only_keys_are_changed'
              }
            }
          }
        }
      ).should == {
        fooBarBaz: {
          someSubHash: {
            aSubSubHash: {
              fooVal: 'abc',
              anotherValue: 'only_keys_are_changed'
            }
          }
        }
      }
    end

    it "should convert a string-keyed hash to camelcase" do
      HashConverter.camelize(
        {
          "foo_bar_baz" => {
            "some_sub_hash" => {
              "a_sub_sub_hash" => {
                "foo_val" => 'abc',
                "another_value" => 'only_keys_are_changed'
              }
            }
          }
        }
      ).should == {
        fooBarBaz: {
          someSubHash: {
            aSubSubHash: {
              fooVal: 'abc',
              anotherValue: 'only_keys_are_changed'
            }
          }
        }
      }
    end
  end
end

