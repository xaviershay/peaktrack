Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/athlete/:athlete_id/region/:region_id', to: 'athletes#show'

  get '/debug/activity/:id', to: 'athletes#debug_activity'
  get '/debug/exception', to: 'misc#debug_exception'

  get '/', to: 'misc#home'
  get '/dashboard', to: 'misc#dashboard'
  get '/auth', to: 'misc#auth'
  get '/help', to: 'misc#help'

  get '/webhook', to: 'misc#webhook_register'
  post '/webhook', to: 'misc#webhook_receive'

  post '/logout', to: 'misc#logout'

  mount GoodJob::Engine => 'good_job'
end
