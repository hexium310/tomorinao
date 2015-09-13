require 'twitter'
require 'yaml'
require 'oauth'
require 'pp'

def register_account
  keys  = YAML.load_file('./consumer.yml')
  oauth = OAuth::Consumer.new(
    keys['twitter']['consumer_key'],
    keys['twitter']['consumer_secret'],
    site: 'https://api.twitter.com'
  )
  get_rt = oauth.get_request_token
  puts "#{get_rt.authorize_url}"
  puts '上記アドレスにアクセスして認証して出てきたPINを入力してください => '
  pin                  = (STDIN.gets.chomp).to_i
  get_at               = get_rt.get_access_token(oauth_verifier: pin)
  @access_token        = get_at.token
  @access_token_secret = get_at.secret
end

def connect_twitter
  keys = YAML.load_file('./consumer.yml')
  puts 'ツイッターに接続中'
  @client = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = keys['twitter']['consumer_key']
    config.consumer_secret     = keys['twitter']['consumer_secret']
    config.access_token        = @access_token
    config.access_token_secret = @access_token_secret
  end

  @rest_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = keys['twitter']['consumer_key']
    config.consumer_secret     = keys['twitter']['consumer_secret']
    config.access_token        = @access_token
    config.access_token_secret = @access_token_secret
  end

  @user_name        = @rest_client.user.name
  @user_screen_name = @rest_client.user.screen_name
  puts '接続成功'
end

def stream
  @client.user do |status|
    next unless status.is_a?(Twitter::Tweet)
    @rest_client.update_profile({name: '友利奈緒'}) if status.text =~ /#{@user_screen_name} update_name/
  end
end

register_account
connect_twitter
stream
