CloudspaceRss::Application.routes.draw do
  resource :feeds do
    get '',                  to: 'feeds#index',                 as: 'index'
    get 'recommended',       to: 'feeds#recommended',           as: 'recommended'
  end
  
  resource :feed_items do
    get '',                  to: 'feed_items#index',            as: 'index'
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

end
