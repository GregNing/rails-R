 class Admin::UsersController < AdminController
  before_action :require_admin!
  #Rails 的 controller 默认会继承自 ApplicationController，
#这里改成继承自 AdminController，这样定义在 app/controllers/admin_controller.rb 
#的所有方法都会被继承下来，包括 layout "admin"
  def index
    # @users = User.all
     @users = User.includes(:groups).all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_users_path
    else
      render "edit"
    end
  end

  protected

  def user_params
    #params.require(:user).permit(:email)
    # params.require(:user).permit(:email, :group_ids => [])
    params.require(:user).permit(:email, :role, :group_ids => [])
  end

end