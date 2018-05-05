#!/usr/bin/env ruby

require 'discordrb'
require 'socket'
require 'json'
require 'trollop'

options = Trollop::options do
  opt :port,  'Which port to listen on', type: :int,  default: 45790
  opt :quiet, 'No output about bots',    type: :bool, default: false
end

server = TCPServer.open(options[:port])
puts "\n🍳 Server started, listening on port #{options[:port]}..."
puts

bots = {}
at_exit do
  server.close
  puts
  puts "\n💤 server closed. bye-bye!"
  puts
end
trap('SIGINT') { exit }

# wait for client to connect
while client = server.accept
  # client has sent a message
  while received = client.gets
    data = JSON.parse(received, symbolize_names: true)

    # just looks cleaner further down.
    character = data[:name].to_sym
    channel_id = data[:channel_id]
    message = data[:message]
    image = data[:image]

    # create bot with this name if it doesn't exist already
    unless bots[character]
      token = data[:token]
      id = data[:client_id]

      bots[character] = Discordrb::Bot.new(token: token,
                                           client_id: id,
                                           log_mode: :quiet)

      puts "🤖 created '#{character}'" unless options[:quiet]

      # start specified bot
      bots[character].run :async
    end

    # send message to discord; post an image first if one was specified
    if image
      File.open(image, 'r') do |f|
        bots[character].send_file(channel_id, f)
      end
    end
    bots[character].send_message(channel_id, "**#{character}:** #{message}")
    puts "💬 #{character}: #{message}" unless options[:quiet]
  end
end

