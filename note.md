# The Elektron WebSocket API Posting to ATS example with Ruby Implementation Detail

## Overview
- The application sends the Off-Stream post message to ADS 3.2 WebSocket connection
- The application supports the following post messages 
    - Create ATS contribution RIC
    - Update ATS contirbution RIC market price data
    - Add ATS contribution fields
    - Remove ATS contribion fields
    - Delete ATS contribution RIC
- The application performs the following steps
    1. Users start application with command line parameter to specify action (create, update, delete, addfields, removefields)
    2. The applciation establishes the WebSocket connection with ADS
    3. The application sends a Login request message to ADS
    4. Once the application receives a Login Refresh message from ADS, it sends JSON post message to ADS based on action parameter in step (1)
    5. Once the application receives Ack message from ADS, the applciation exit
- The application is modified from Elektron WebSocket API's market_price_posting.rb example.

Please find the application overview, installation, references in [README.md](./README.md) file.

## Code Changes from market_price_posting.rb

1. The market_price_posting.rb automatic gets user's IP address and sends it to ADS as a Post message's user information. That IP Address could be IPV6 Address which ADS server does not support. The market_price_postapp.rb changes this behavior to send IPV4 Address to ADS.

    **market_price_posting.rb**
    ```

    $position = Socket.ip_address_list[0].ip_address #Can be IPV6
    ```
    **market_price_postapp.rb**
    ```
    # get IPV4 from user machine as a default position information
    addr_infos = Socket.ip_address_list
    addr_infos.each do |addr_info|
        if addr_info.ipv4? and !addr_info.ipv4_loopback?
            $position = addr_info.ip_address
        end
    end
    ```
2. The application supports "--action" parameter to let users specify which Post message they want the application sends to ADS.

    **market_price_postapp.rb**
    ```
    $action = 'update'
    ...
    # Get command line parameters
    opt_parser = OptionParser.new do |opt|

        ...

        opt.on('--action ACTION','ACTION') do |action|
            $action = action
        end
    
        opt.on('--help','HELP') do |help|
            puts 'Usage: market_price.rb [--hostname hostname] [--port port] [--app_id app_id] [--user user] [--position position] [--action {create, addfields, removefields, delete, update}][--help]'
            exit 0
        end
    end
    ```
3. The application does not send the Market Price request message to the ADS server. Instead, it sends the Post message based on action parameter.

    **market_price_posting.rb**
    ```
    # Parse at high level and output JSON of message
    def process_message(ws, message_json)
        message_type = message_json['Type']

        if message_type == 'Refresh' then
            message_domain = message_json['Domain']
            if message_domain != nil then
                if message_domain == 'Login' then
                    send_market_price_request(ws)
                end
            end
    ```

    **market_price_postapp.rb**
    ```

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
    ```
4. The application sends Post message via the following functions
    - create_ric_post(): Create contribution RIC in ATS by simple Market Price post
    - add_fields_post(): Add fields to ATS's contribution RIC by simple Market Price post
    - remove_fields_post(): Remove fields from ATS's contribution RIC by simple Market Price post
    - delete_ric_post(): Remove ATS's contribution RIC by simple Market Price post
    - update_market_price_post(): Update market data to ATS's contribution field by simple Market Price post

    All functions do the same thing, create the JSON object with Ruby hash, then send it to ADS with WebSocket.send() function.

5. The market_price_posting.rb application sends On-stream post message but market_price_postapp.rb application sends Off-stream post message. 

    **market_price_posting.rb**
    ```
    # Create and send simple Market Price post
    def send_market_price_post(ws)
        mp_post_json_hash = {
            'ID' => 2, #Item Stream
            'Type' => 'Post',
            'Domain' => 'MarketPrice',
            'Ack' => true,
            'PostID' => $post_id,
            'PostUserInfo' =>  {
                'Address' => $position, # Use the IP address as the Post User Address.
                'UserID' => Process.pid # Use our current process ID as the Post User Id.
            },
                'Message' => {
                'ID' => 0,
                'Type' => 'Update',
                'Fields' => {'BID' => 45.55,'BIDSIZE' => 18, 'ASK' => 45.57, 'ASKSIZE' => 19}
            }
        }
    ```
    **market_price_postapp.rb**
    ```
    # Create contribution RIC in ATS by simple Market Price post
    def create_ric_post(ws)
        mp_post_json_hash = {
            'ID' => 1, #Login Stream
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
                'Fields' => {'X_RIC_NAME' => 'CREATED.RIC' ,'BID' => 12, 'ASK' => 15}
            }
        }
    ```

## Running the application 

Users can run this application in command line/console via the following command

```$> ruby market_price_postapp.rb [--hostname hostname ] [--port WebSocket port] [--app_id appID] [--user user] [--action {{create, addfields, removefields, delete, update}}]```

## Example Messages 

### Create ATS contribution RIC example JSON message
```
{
  "ID": 1, 
  "Type": "Post",
  "Domain": "MarketPrice",
  "Ack": true,
  "PostID": 1,
  "PostUserInfo": {
    "Address": "<Machine IP Address>",
    "UserID": <USER ID>
  },
  "Key": {
    "Name": "ATS_INSERT_S", # RIC name for create ATS server contribution RIC
    "Service": <ADS Service ID that connects to ATS server>
  },
  "Message": {
    "ID": 0,
    "Type": "Refresh",
    "Domain": "MarketPrice",
    "Fields": {
      "X_RIC_NAME": "<Contribution RIC name>",
      "BID": 12,
      "ASK": 15
    }
  }
}
```
### Update market price data to contribution RIC example
```
{
  "ID": 1,
  "Type": "Post",
  "Domain": "MarketPrice",
  "Ack": true,
  "PostID": 1,
  "PostUserInfo": {
    "Address": "<Machine IP Address>",
    "UserID": <USER ID>
  },
  "Key": {
    "Name": "<Contribution RIC name>",
    "Service": <ADS Service ID that connects to ATS server>
  },
  "Message": {
    "ID": 0,
    "Type": "Update",
    "Domain": "MarketPrice",
    "Fields": {
      "BID": 43,
      "ASK": 46
    }
  }
}
```

### Posting with wrong Service ID 
```
RECEIVED:
[
  {
    "ID": 1,
    "Type": "Ack",
    "AckID": 1,
    "NakCode": "DeniedBySrc",
    "Text": "Unable to find service for post message.",
    "Key": {
      "Service": 9999,
      "Name": "ATS_INSERT_S"
    }
  }
]
```

### Posting to unavailable Service ID
```
RECEIVED:
[
  {
    "ID": 1,
    "Type": "Ack",
    "AckID": 1,
    "NakCode": "SourceDown",
    "Text": "A9: Service is unavailable.",
    "Key": {
      "Service": "NI_PUB",
      "Name": "ATS_INSERT_S"
    }
  }
]
```