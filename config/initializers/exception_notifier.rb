if Rails.env.production?
  Peaktrack::Application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[PF] ",
      :sender_address => %{"notifier" <contact+exceptions@xaviershay.com>},
      :sections => %w{request environment backtrace},
      :exception_recipients => %w{
        contact+exceptions@xaviershay.com
      }
    }
end
