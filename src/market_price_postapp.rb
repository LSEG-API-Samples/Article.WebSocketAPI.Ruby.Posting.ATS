#!/usr/bin/ruby
# * Simple example of outputting Market Price JSON data using Websockets

require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'optparse'
require 'socket'

# Global Default Variables
$hostname = '127.0.0.1'
$port = '15000'
$user = 'api'
$app_id = '256'
$action = 'update'

# get IPV4 from user machine as a default position information
addr_infos = Socket.ip_address_list
addr_infos.each do |addr_info|
    if addr_info.ipv4? and !addr_info.ipv4_loopback?
        $position = addr_info.ip_address
    end
end

# Global Variables
$is_item_stream_open = false
$post_id = 1

# Get command line parameters
opt_parser = OptionParser.new do |opt|

  opt.on('--hostname HOST','HOST') do |hostname|
    $hostname = hostname
  end

  opt.on('--port port','port') do |port|
    $port = port
  end

  opt.on('--user USER','USER') do |user|
    $user = user
  end

  opt.on('--app_id APP_ID','APP_ID') do |app_id|
    $app_id = app_id
  end

  opt.on('--position POSITION','POSITION') do |position|
    $position = position
  end

  opt.on('--action ACTION','ACTION') do |action|
    $action = action
  end
  
  opt.on('--help','HELP') do |help|
	puts 'Usage: market_price.rb [--hostname hostname] [--port port] [--app_id app_id] [--user user] [--position position] [--action {create, addfields, removefields, delete, update}][--help]'
	exit 0
  end
end

opt_parser.parse!

# Check if user inputs unsupported action value
if !['create','addfields','removefields','delete','update'].include?($action)
  puts "Received unsupported action value, exit application. Support action values are {create, addfields, removefields, delete, update}"
  exit 1
end


# Create RIC in ATS by simple Market Price post
def create_ric_post(ws)
    mp_post_json_hash = {
    'ID' => 1,
    'Type' => 'Post',
    'Domain' => 'MarketPrice',
    'Ack' => true,
    'PostID' => $post_id,
    'PostUserInfo' =>  {
      'Address' => $position, # Use the IP address as the Post User Address.
      'UserID' => Process.pid
    },
    'Key' => {
        'Name' => 'ATS_INSERT_S', # RIC name for create ATS server contribution RIC
        'Service' => 668 # ADS Service ID that connects to ATS server
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Refresh',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'CREATED.RIC' ,'BID' => 47.55,'BIDSIZE' => 35, 'ASK' => 51.57, 'ASKSIZE' => 40}
    }
  }
  ws.send mp_post_json_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(mp_post_json_hash)

  $post_id += 1
end 

# Add fields in ATS's contribution RIC by simple Market Price post
def add_fields_post(ws)
  mp_post_json_hash = {
    'ID' => 1,
    'Type' => 'Post',
    'Domain' => 'MarketPrice',
    'Ack' => true,
    'PostID' => $post_id,
    'PostUserInfo' =>  {
      'Address' => $position, # Use the IP address as the Post User Address.
      'UserID' => Process.pid
    },
    'Key' => {
        'Name' => 'ATS_ADDFIELD_S', # RIC name for add fields to ATS server contribution RIC
        'Service' => 668 # ADS Service ID that connects to ATS server
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'CREATED.RIC' ,'DSPLY_NAME' => 'Blackstone','TRDPRC_1' => 70.99 }
    }
  }
  ws.send mp_post_json_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(mp_post_json_hash)

  $post_id += 1
end

# Remove fields in ATS's contribution RIC by simple Market Price post
def remove_fields_post(ws)
  mp_post_json_hash = {
    'ID' => 1,
    'Type' => 'Post',
    'Domain' => 'MarketPrice',
    'Ack' => true,
    'PostID' => $post_id,
    'PostUserInfo' =>  {
      'Address' => $position, # Use the IP address as the Post User Address.
      'UserID' => Process.pid
    },
    'Key' => {
        'Name' => 'ATS_DELETE', # RIC Name for remove fields for ATS server contribution RIC
        'Service' => 668 # ADS Service ID that connects to ATS server
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'CREATED.RIC' ,'TRDPRC_1' => 70.99 }
    }
  }
  ws.send mp_post_json_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(mp_post_json_hash)

  $post_id += 1
end

def delete_ric_post(ws)
  mp_post_json_hash = {
    'ID' => 1,
    'Type' => 'Post',
    'Domain' => 'MarketPrice',
    'Ack' => true,
    'PostID' => $post_id,
    'PostUserInfo' =>  {
      'Address' => $position, # Use the IP address as the Post User Address.
      'UserID' => Process.pid
    },
    'Key' => {
        'Name' => 'ATS_DELETE_ALL', # RIC Name for remove ATS server contribution RIC
        'Service' => 668 # ADS Service ID that connects to ATS server
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'CREATED.RIC'}
    }
  }
  ws.send mp_post_json_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(mp_post_json_hash)

  $post_id += 1
end

# Create and send simple Market Price post
def update_market_price_post(ws)
  mp_post_json_hash = {
    'ID' => 1,
    'Type' => 'Post',
    'Domain' => 'MarketPrice',
    'Ack' => true,
    'PostID' => $post_id,
    'PostUserInfo' =>  {
      'Address' => $position, # Use the IP address as the Post User Address.
      'UserID' => Process.pid
    },
    'Key' => {
        'Name' => 'CREATED.RIC', # ATS server contribution RIC name
        'Service' => 668
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'BID' => 45.55,'BIDSIZE' => 18, 'ASK' => 45.57, 'ASKSIZE' => 19}
    }
  }
  ws.send mp_post_json_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(mp_post_json_hash)

  $post_id += 1
end

# Parse at high level and output JSON of message
def process_message(ws, message_json)
  message_type = message_json['Type']

  if message_type == 'Refresh' then
    message_domain = message_json['Domain']
	  if message_domain != nil then
      if message_domain == 'Login' then
        # send POST message based on user input action value
        case $action
          when 'create'
            create_ric_post(ws)
          when 'addfields'
            add_fields_post(ws)
          when 'removefields'
            remove_fields_post(ws)
          when 'delete'
            delete_ric_post(ws)
          when 'update'
            update_market_price_post(ws)
          else 
            puts "Received unsupported action, exit application"
            exit 1
        end
    end
  end
  elsif message_type == 'Ping' then
    pong_json_hash = {
	    'Type' => 'Pong',
    }
    ws.send pong_json_hash.to_json.to_s
    puts 'SENT:'
    puts JSON.pretty_generate(pong_json_hash)
  elsif message_type == 'Ack' then
    puts "RECEIVED: Ack from #{$hostname}:#{$port}, exit application"
    exit 0
  end
end

# Start websocket handshake
ws_address = "ws://#{$hostname}:#{$port}/WebSocket"
puts "Connecting to WebSocket #{ws_address} ..."
ws = WebSocket::Client::Simple.connect(ws_address,{:headers => {'Sec-WebSocket-Protocol' => 'tr_json2'}})

# Called when message received, parse message into JSON for processing
ws.on :message do |msg|
  msg = msg.to_s

  puts 'RECEIVED:'

  json_array = JSON.parse(msg)

  puts JSON.pretty_generate(json_array)

  for single_msg in json_array
    process_message(ws, single_msg)
  end

end

# Called when handshake is complete and websocket is open, send login
ws.on :open do
  puts 'WebSocket successfully connected!'

  login_hash = {
    'ID' => 1,
    'Domain' => 'Login',
    'Key' => {
      'Name' => '',
      'Elements' => {
        'ApplicationId' => '',
        'Position' => ''
      }
    }
  }

  login_hash['Key']['Name'] = $user
  login_hash['Key']['Elements']['ApplicationId'] = $app_id
  login_hash['Key']['Elements']['Position'] = $position

  ws.send login_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(login_hash)
end

# Called when websocket is closed
ws.on :close do |e|
  puts 'CLOSED'
  p e
  exit 1
end

# Called when websocket error has occurred
ws.on :error do |e|
  puts 'ERROR'
  p e
end

sleep
