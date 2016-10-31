require 'socket'
require './lib/url'
require 'pry'

begin  # Tied in with the rescue way below for CTRL-C

ActiveRecord::Base.establish_connection YAML.load_file('db/config.yml')[ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"]

binding.pry

server = TCPServer.new 2000

def redirect(url)
<<REDIRECT
HTTP/1.1 302 Found
Location: #{url}

REDIRECT
end

loop do
  # Sit by the phone and wait for incoming requests
  stuff = server.accept
  # Grab just the request part (big string of stuff)
  request = stuff.recvmsg.first
  # OK sometimes it's empty, in which case cut things short
  next if request.empty?
  # Find the first carriage return, so the end of the first line
  end_of_first_line = request.index("\n")
  # Show the first line
  first_line = request[0..end_of_first_line].strip
  path = first_line.split(" ")[1]

  stuff.puts(redirect(path[5..-1]))
end

rescue Interrupt
  puts "Someone pressed CTRL-C"
ensure
  ActiveRecord::Base.connection.close
  puts "Closed the database connection!"
end
