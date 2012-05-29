require "JSON"
require "redis"

class ShortUrl
# = Description 
# This class store the url and the Short URL.
#It also Generate the short_url code and save all data to a _Redis_ SET.

SHORT_URL_CHARACTERS_RANGE = %{ 0 1 2 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} #This constant describes the character range of the characters that for the short_url code.   
attr_reader :url, :short_url, :generate_short_url
  
  def initialize(raw_url,url = 'a')
    @url       = raw_url
    @short_url = url
  end
  def to_json(*a)
    {"json_class" => self.class.name, "data" => {"url" => @url, "short_url" => @short_url }}.to_json(*a)
  end
  def self.json_create(o)
    new(o["data"]["url"], o["data"]["short_url"])
  end
  def clean_url(raw_url)     #This method strip whitespaces and add the http prefix to the url if it's missing.
    clean_url = raw_url.strip
    clean_url = "http://" + clean_url if clean_url[0..6] != "http://"
    return clean_url
  end
  def generate_short_url
    urldb = Redis.new
    list =  Array.new
    urldb.set("url_list", '{"json_class":"ShortUrl","data":{"url":"http://foo.bar","short_url":"a"}}') if urldb.get("url_list") == nil    
    list << JSON.parse(urldb.get("url_list"))
    last_short_url = list.pop
    last_short_code = last_short_url.short_url
    list.push last_short_url
    puts last_short_code
    puts list.inspect
  end
  def remove
    urldb = Redis.new
    urldb.del "url_list"
    puts urldb.dbsize
  end
end

s = ShortUrl.new("http://foo.bar")
s.generate_short_url
#s.remove