class AuthLabsController < ApplicationController
  def show
    @current_user = Current.session.user
  end
end
