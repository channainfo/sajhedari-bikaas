class UsersController < ApplicationController  
  before_filter :authenticate_user!

  def index
    if params[:query]
      @query = params[:query]
      @users = User.where('last_name like ? OR first_name like ? OR phone_number like ?',"%#{@query}%","%#{@query}%","%#{@query}%").paginate(:page => params[:page], :per_page => 10)
    else
      @users = User.all.paginate(:page => params[:page], :per_page => PageSize)
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
    @user.date_of_birth = DateTime.strptime(params["user"]["date_of_birth"], "%m-%d-%Y")  unless params["user"]["date_of_birth"].strip.empty?
    if @user.create_to_resourcemap
      if @user.save
        flash[:notice] = "You have successfully created user #{@user.first_name} #{@user.last_name}."
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
    @user.date_of_birth = @user.date_of_birth.strftime("%m-%d-%Y") if @user.date_of_birth
    assign_role_list
  end

  def edit_profile
    @user = current_user
    assign_role_list
  end

  def change_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.valid_password? params["user"]["current_password"]
      if @user.update_password_to_resourcemap params[:user]
        if(@user.update_attributes!(params[:user]))
          flash[:notice] = "You have successfully updated user #{@user.first_name} #{@user.last_name}."
          redirect_to users_path
        else
          flash[:error] = "Failed to update user password. Please try again later."
          render :change_password
        end
      else
        flash[:error] = "Failed to update user password on resource map application. Please try again later."
        render :change_password
      end
    else
      @user.errors.add(:current_password, " does not match" )
      render :change_password
    end
  end

  def update
    @user = User.find(params[:id])
    if(params["user"]["password"] != "" and params["user"]["password_confirmation"] != "")
      if(params["user"]["password"] == params["user"]["password_confirmation"])
        if @user.update_to_resourcemap params[:user]
          if(@user.update_attributes!(params[:user]))
            @user.date_of_birth = DateTime.strptime(params["user"]["date_of_birth"], "%m-%d-%Y")  unless params["user"]["date_of_birth"].strip.empty?
            @user.save
            flash[:notice] = "You have successfully updated user #{@user.first_name} #{@user.last_name}."
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
      else
        flash[:error] = "Password and Password confirmation is not match"
        assign_role_list
        render :edit
      end
    else
      params["user"].delete("password")
      params["user"].delete("password_confirmation")
      if @user.update_to_resourcemap params[:user]
        if(@user.update_attributes!(params[:user]))
            @user.date_of_birth = DateTime.strptime(params["user"]["date_of_birth"], "%m-%d-%Y")  unless params["user"]["date_of_birth"].strip.empty?
            @user.save
            flash[:notice] = "You have successfully updated user #{@user.first_name} #{@user.last_name}."
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
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy_from_resourcemap
      if @user.destroy      
        flash[:notice] = "You have successfully deleted user #{@user.first_name} #{@user.last_name}."
        redirect_to users_path
      else
        flash[:error] = "Failed to delete user #{@user.first_name} #{@user.last_name}. Please try again later."
        redirect_to users_path
      end
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