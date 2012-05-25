require File.dirname(__FILE__)+"/../encurta.rb"

describe ShortUrl do
  it "Stores URL, and a valid Shorten URL" do
    s_url = ShortUrl.new("http://foo.bar")
    s_url.url.should == "http://foo.bar"
    s_url.short_url.should == nil
  end
  it "Should generate a short url composed of, up to 4 characters"
  it "short url characters shoud range from 0 to 9, then a to z, then A to Z"
  it "should save to a Redis SET, as a JSON string"
end