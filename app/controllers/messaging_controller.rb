require 'digest'

class MessagingController < ApplicationController
  protect_from_forgery :except => :index

  USER_NAME, PASSWORD = 'iLab', '1c4989610bce6c4879c01bb65a45ad43'

  # POST /messaging
  def index
    message = save_message params
    begin
      message.process!
    rescue => err
      message.reply = err.message
    ensure
      render :text => message.reply, :content_type => "text/plain"
    end
    # message.save
  end

  def authenticate
    authenticate_or_request_with_http_basic 'Dynamic Resource Map - HTTP' do |username, password|
      USER_NAME == username && PASSWORD == Digest::MD5.hexdigest(password)
    end
  end

  def save_message params
    Message.create!(:guid => params[:guid], :from => params[:from], :body => params[:body]) do |m|
      m.country = params[:country]
      m.carrier = params[:carrier]
      m.channel = params[:channel]
      m.application = params[:application]
      m.to = params[:to]
    end
  end

end
