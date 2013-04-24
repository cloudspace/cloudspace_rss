CloudspaceRss::Application.routes.draw do
  resource :feeds do
    get '',                  to: 'feeds#index',                 as: 'index'
    get 'recommended',       to: 'feeds#recommended',           as: 'recommended'
    get 'combined',          to: 'feeds#combined',              as: 'combined'
  end
  
  resource :feed_items do
    get '',                  to: 'feed_items#index',            as: 'index'
    get ':id/thumbnail',     to: 'feed_items#thumbnail',        as: 'thumbnail'
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

end
