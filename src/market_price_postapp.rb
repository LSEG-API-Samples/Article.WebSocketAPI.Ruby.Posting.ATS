#!/usr/bin/ruby
# * Simple example of outputting Market Price JSON data using Websockets

require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'optparse'
require 'socket'

# Global Default Variables
$hostname = '172.20.33.11'
$port = '15000'
$user = 'api'
$app_id = '256'
#$position = Socket.ip_address_list[1].ip_address
$action = 'update'

addr_infos = Socket.ip_address_list
addr_infos.each do |addr_info|
    puts addr_info.ip_address
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
	puts 'Usage: market_price.rb [--hostname hostname] [--port port] [--app_id app_id] [--user user] [--position position] [--action {create, addfields, deletefield, delete, update}][--help]'
	exit 0
  end
end

opt_parser.parse!



# Create and send simple Market Price batch request with view
def send_market_price_request(ws)
  mp_req_json_hash = {
    'ID' => 2,
    'Key' => {
      'Name' => 'TRI.N'
    }
  }
  ws.send mp_req_json_hash.to_json.to_s
  puts 'SENT:'
  puts JSON.pretty_generate(mp_req_json_hash)
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
        'Name' => 'ATS_INSERT_S',
        'Service' => 668
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Refresh',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'WASINCREATE2.BK' ,'BID' => 47.55,'BIDSIZE' => 35, 'ASK' => 51.57, 'ASKSIZE' => 40}
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
        'Name' => 'ATS_ADDFIELD_S',
        'Service' => 668
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'WASINCREATE2.BK' ,'DSPLY_NAME' => 'Blackstone','TRDPRC_1' => 70.99 }
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
        'Name' => 'ATS_DELETE',
        'Service' => 668
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'WASINCREATE2.BK' ,'TRDPRC_1' => 70.99 }
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
        'Name' => 'ATS_DELETE_ALL',
        'Service' => 668
    },
    'Message' => {
      'ID' => 0,
      'Type' => 'Update',
      'Domain' => 'MarketPrice',
      'Fields' => {'X_RIC_NAME' => 'WASINCREATE2.BK'}
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
        'Name' => 'WASINCREATE2.BK',
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
        case $action
          when 'create'
            create_ric_post(ws)
          when 'addfield'
            add_fields_post(ws)
          when 'removefield'
            remove_fields_post(ws)
          when 'delete'
            delete_ric_post(ws)
          when 'update'
            update_market_price_post(ws)
          else 
            send_market_price_request(ws)
        end
	  end
	end

    if message_json['ID'] == 2 and not $is_item_stream_open and
        (message_json['State'] == nil or (message_json['State']['Stream'] == 'Open' and message_json['State']['Data'] == 'Ok')) then
      # Our TRI.N stream is now open. We can start posting content.
      $is_item_stream_open = true
      Thread.new do
        loop do
          sleep 3
          #send_market_price_post(ws)
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
