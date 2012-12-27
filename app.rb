require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///db/shortened_urls.db'
set :address, 'localhost:9393'

class ShortenedUrl < ActiveRecord::Base
  validates_uniqueness_of :url
  validates_presence_of :url
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "The URL must start with http://, https://, or ftp:// ."
end


get '/' do
	haml :index
end

post '/' do
  @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
  if @short_url.valid?
    haml :success, :locals => { :address => settings.address }
  else
    haml :index
  end
end

get '/:shortened' do
  short_url = ShortenedUrl.find(params[:shortened].to_i(32))
  redirect short_url.url
end
