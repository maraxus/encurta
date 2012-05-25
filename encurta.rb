require "JSON"
require "redis"

class ShortUrl
# = Description 
# This class store the url and the Short URL.
#It also Generate the short_url code and save all data to a _Redis_ SET.

SHORT_URL_CHARACTERS_RANGE = %{ 0 1 2 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} #This constant describes the character range of the characters that for the short_url code.   
attr_reader :url, :short_url, :generate_short_url
  
  def initialize(raw_url)
    @url       = raw_url
    @short_url = "a"
  end
  def to_json(*a)
    {"json_class" => self.class.name, "data" => {"string" => @url, "string" => @short_url }}.to_json(*a)
  end
  def clean_url(raw_url)     #This method strip whitespaces and add the http prefix to the url if it's missing.
    clean_url = raw_url.strip
    clean_url = "http://" + clean_url if clean_url[0..6] != "http://"
    return clean_url
  end
  def generate_short_url
    urldb = Redis.new
    
    if urldb.dbsize == 0
      urldb.set("url_list", "first") #'SET' requires two arguments ever, 'first' is a meaningless piece of data
    else
      list = JSON.parse(urldb.get("url_list"))
    end
    list.inspect
  end
end

s = ShortUrl.new("http://foo.bar")
puts s.inspect
t = s.to_json
puts t