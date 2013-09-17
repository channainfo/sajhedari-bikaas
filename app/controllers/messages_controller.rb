class MessagesController < ApplicationController  
  before_filter :authenticate_user!

  def destroy
    Message.find(params[:id]).destroy!
    redirect_to failed_messages_conflict_cases_path
  end
end