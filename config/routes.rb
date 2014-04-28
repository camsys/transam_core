Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'admin'

  resources :inventory, :controller => 'assets' do
      collection do
        get 'filter'
        get 'details'
        get 'new_asset'
        get 'export'
        get 'back'
        get 'map'
        get 'spatial_filter'
      end
      member do
        get 'update_status'
        get 'copy'
      end
    resources :asset_events    
    resources :notes    
    resources :attachments do
      member do
        get 'download'
      end
    end
  end
      
  resources :organizations, :path => "org", :only => [:index, :show, :edit, :update] do
    member do
      get 'map'
    end
  end

  resources :dashboards, :only => [:index, :show]
  resources :searches, :only => [:new, :create]
  resources :reports, :only => [:index, :show] do
    member do
      get 'load'  # load a report using ajax
    end
  end
  
  resources :uploads do
    collection do
      get   'templates'
      post  'create_template'
    end
    member do
      get   'resubmit'
    end
  end 
  
  resources :users do
    collection do
    end
    member do
      post  'set_current_org'
      get   'change_password'
      patch 'update_password'
    end
    resources :messages
    resources :tasks do
      collection do
        get   'filter'
      end
      member do
        patch 'update_status'
      end
    end
  end
      
  resources :policies do
    member do
      get   'copy'
    end
  end
  
  # default root for the site -- will be /org/:organization_id/dashboards
  root :to => 'dashboards#index'
  
end
