#!/usr/bin/env ruby

# a tiny client to roleplay as npcs with.
# expects a .json file with character data called 'characters.json'
# character data can potentially include tokens and client_ids.
# also expects a .json file with a channel_id, a token and a client_id.

require 'socket'
require 'json'
require 'readline'

HOST = 'localhost'
PORT = 45790
SHOW_CHARACTER_BIOS = true

def read_json(file)
  File.open(file, 'r') { |f| JSON.parse(f.read, symbolize_names: true) }
end

secrets    = read_json('secrets.json')
characters = read_json('characters.json')
AUTOCOMPLETION_LIST = characters.keys.sort

server = TCPSocket.open(HOST, PORT)
at_exit { puts 'bye-bye!'; server.close }

# don't append a character after autocompletion
Readline.completion_append_character = nil
# automcompletion looks at the entire line, not just the last word
Readline.completer_word_break_characters = ''
# enable autocompletion of character names
Readline.completion_proc = proc do |s|
  AUTOCOMPLETION_LIST.grep(/#{Regexp.escape(s)}/)
end

# convenience method for using readline with history
# also allows safe exiting out of program at any input
def read(sym: '> ')
  input = Readline.readline(sym, true)
  exit if input == '/exit' || input == ':q'
  input
end

loop do
  # write npc selection menu with bios
  if SHOW_CHARACTER_BIOS
    characters.keys.each do |name|
      puts "\e[34m#{name}\e[0m:"
      puts characters[name][:bio]
      puts
    end
  end

  puts "Select NPC by name: "
  selected = ''
  until characters.keys.include?(selected = read.to_sym)
    puts "Invalid character name. Please try again:"
  end

  puts "\nEnter message as #{selected}:"
  message = read
  next if message == '/back'
  puts

  # build json to send to server
  # use character-specific token and client_id, if supplied.
  data = {
    name: selected,
    token: characters[selected][:token] || secrets[:token],
    client_id: characters[selected][:client_id] || secrets[:client_id],
    channel_id: secrets[:channel_id],
    image: characters[selected][:portrait],
    message: message
  }.to_json

  server.puts(data)
  puts '=' * 80
  puts
end
