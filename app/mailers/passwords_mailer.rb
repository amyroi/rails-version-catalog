class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @reset_url = edit_password_url(user.password_reset_token)
    mail subject: I18n.t("passwords_mailer.reset.subject"), to: user.email_address
  end
end
