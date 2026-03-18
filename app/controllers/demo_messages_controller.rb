class DemoMessagesController < ApplicationController
  allow_unauthenticated_access

  def create
    @demo_message = DemoMessage.new(message_params)
    @demo_message.author = Current.session&.user&.email_address.presence || @demo_message.author

    if @demo_message.save
      redirect_to feature_path("solid-cable"), notice: "Message broadcast."
    else
      redirect_to feature_path("solid-cable"), alert: @demo_message.errors.full_messages.to_sentence
    end
  end

  private
    def message_params
      params.expect(demo_message: [ :author, :body ])
    end
end
