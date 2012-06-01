require "JSON"
require "redis"

class ShortUrl
# = Description 
# This class store the url and the Short URL.
#It also Generate the short_url code and save all data to a _Redis_ SET.

SHORT_URL_CHARACTERS_RANGE = %w{ 0 1 2 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} #This constant describes the character range of the characters that for the short_url code.   
attr_reader :url, :short_url, :generate_short_url
  
  def initialize(raw_url,url = '0')
    @url       = clean_url(raw_url)
    @short_url = url
  end
  def to_json(*a)
    {"json_class" => self.class.name, "data" => {"url" => @url, "short_url" => @short_url }}.to_json(*a).gsub!(%r[\"],"\"")
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
    next_character = Array.new
    new_short_url = String.new
    puts urldb.llen("url_list")
    if urldb.llen("url_list") == 0
      urldb.rpush("url_list", {"json_class"=>"ShortUrl","data"=>{"url"=>"http://foo.bar","short_url"=>"0"}}.to_json.gsub!(%r[\"],"\""))
    end
    last_short_url = JSON.parse(urldb.rpop("url_list"))
    urldb.rpush("url_list", last_short_url.to_json)
    puts "last short url: " + last_short_url.inspect
    last_short_code = last_short_url.short_url
    
    next_c = SHORT_URL_CHARACTERS_RANGE.index last_short_code.slice(%r[\w$])
    puts next_c
    next_c += 1
    next_character = SHORT_URL_CHARACTERS_RANGE.at(next_c)
    if next_character.nil?
      new_short_url = last_short_code << "0"
      if new_short_url.length > 4
        new_short_url = '0'
      end
    end
    new_short_url = last_short_code.gsub %r[\w$], next_character
    puts new_short_url + " nova url"
    return new_short_url
  end
  def save
    urldb = Redis.new
    @short_url = generate_short_url
    urldb.rpush "url_list", self.to_json
    puts "regiters: "
    puts urldb.llen("url_list")
  end
  def remove
    urldb = Redis.new
    urldb.del "url_list"
    urldb.del "url_counter"
    return urldb.dbsize
  end
end

s = ShortUrl.new("http://foo.bar")
t = "{\"json_class\":\"ShortUrl\",\"data\": {\"url\":\"http://foo.bar\",\"short_url\":\"0\"}}"
puts t
u = JSON.parse(t)
#v = s.to_json.gsub!(%r[\"],"\\\"")
#puts v
#v = JSON.parse(v)
#puts u.inspect
#puts v.inspect
s.save
#s.remove