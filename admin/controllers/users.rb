Admin.controllers :users do

  get :index do
    @users = User.order_by([:notifications_count, -1]).paginate(page: params[:page])
    render 'users/index'
  end

  get :new do
    @user = User.new
    render 'users/new'
  end

  post :create do
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect url(:users, :edit, :id => @user.id)
    else
      render 'users/new'
    end
  end

  get :edit, :with => :id do
    @user = User.find(params[:id])
    render 'users/edit'
  end

  put :update, :with => :id do
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect url(:users, :edit, :id => @user.id)
    else
      render 'users/edit'
    end
  end

  get :show, :with => :id do
    @user = User.find(params[:id])
    @user_notifications = @user.notifications.paginate(page: params[:page])
    render 'users/show'
  end

  delete :destroy, :with => :id do
    user = User.find(params[:id])
    if user.destroy
      flash[:notice] = 'User was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy User!'
    end
    redirect url(:users, :index)
  end

  delete :destroy_token, :with => [:user_id, :token_type, :token_id] do
    if params[:token_type] == "apn"
      token = User.find(params[:user_id]).apn_device_tokens.where(id: params[:token_id]).destroy
    else
      token = User.find(params[:user_id]).gcm_device_tokens.where(id: params[:token_id]).destroy
    end
    flash[:notice] = 'Token was successfully destroyed.'
    redirect url(:users, :show, :id => params[:user_id])
  end
end
