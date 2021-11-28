Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/athlete/:athlete_id/region/:region_id', to: 'athletes#show'

  get '/debug/activity/:id', to: 'athletes#debug_activity'
end
