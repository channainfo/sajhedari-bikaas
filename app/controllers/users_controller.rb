class UsersController < ApplicationController  
  before_filter :authenticate_user!

  def index
    if params[:query]
      @query = params[:query]
      @users = User.where('last_name like ? OR first_name like ? OR phone_number like ?',"%#{@query}%","%#{@query}%","%#{@query}%").paginate(:page => params[:page], :per_page => 3)
    else
      @users = User.all.paginate(:page => params[:page], :per_page => 3)
    end
    
  end

  def show
  	
  end

  def new
  	@user = User.new()
    assign_role_list
  end

  def create
    
  end

  def register
    @user = User.new(params[:user])
    if @user.create_to_resourcemap
      if @user.save
        flash[:notice] = "You have successfully create user #{@user.first_name} #{@user.last_name}."
        redirect_to users_path
      else
        flash[:error] = "Failed to save record. Please try again later."
        assign_role_list
        render :new
      end
    else
      flash[:error] = "Failed to create user on resource map application. Please try again later."
      assign_role_list
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    assign_role_list
  end

  def update
    @user = User.find(params[:id])
    if @user.update_to_resourcemap params[:user]
      if(@user.update_attributes!(params[:user]))
        flash[:notice] = "You have successfully update user #{@user.first_name} #{@user.last_name}."
        redirect_to users_path
      else
        flash[:error] = "Failed to update user. Please try again later."
        assign_role_list
        render :edit
      end
    else
      flash[:error] = "Failed to update user on resource map application. Please try again later."
      assign_role_list
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy      
      flash[:notice] = "You have successfully delete user #{@user.first_name} #{@user.last_name}."
      redirect_to users_path
    else
      flash[:error] = "Failed to delete user #{@user.first_name} #{@user.last_name}. Please try again later."
      redirect_to users_path
    end
  end

  def assign_role_list
    if is_super_admin? current_user 
      @roles = Role.all
    else
      @roles = Role.where('name=?',"Admin").all
    end
  end
end