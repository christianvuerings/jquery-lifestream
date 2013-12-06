# No need to load the Rails environment for this test.
require 'calcentral_config'

describe CalcentralConfig do
  it "should make safe deep property structures" do
    h = {
        this: "that",
        "stringykey" => "stringyval",
        top: {middle: {bottom: 7}},
        items: [
            {name: "first"},
            {name: "second"}
        ]
    }
    props = CalcentralConfig.deep_open_struct(h)
    props.this.should == "that"
    props.stringykey.should == "stringyval"
    props.top.middle.bottom.should == 7
    props.notyet.should be nil
    props.top.key.should be nil
    props.items[1].name.should == "second"
  end
end
