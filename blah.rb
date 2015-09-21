require 'net/http'

uri = URI('https://stream.twitter.com/1.1/statuses/sample.json?delimited=length')

username = 'scratchwork'
password = 'lasombra1'

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new uri
  request.basic_auth username, password

  http.request request do |response|
    # response.read_body do |chunk|
    #   puts chunk
    # end
  end
end
