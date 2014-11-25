Rails.application.routes.draw do

  devise_for :users, :controllers => { :sessions => "sessions", :unlocks => "unlocks", :passwords => "passwords" }

  # server static pages
  get "/pages/*id" => 'pages#show', :as => :page, :format => false
  
  # route errors to the appropriate pages
  %w( 404 403 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  # Routes for the issues controller
  resources :issues,    :only => [:new, :create] do
    member do
      get 'success'
    end
  end

  resources :vendors
  
  resources :inventory, :controller => 'assets' do
      collection do
        get 'filter'
        get 'details'
        get 'new_asset'
        get 'export'
      end
      member do
        get 'update_status'
        get 'copy'
        get 'add_to_group'
        get 'remove_from_group'
      end
      
    resources :asset_events    
        
    resources :comments,    :only => [:create, :update, :edit, :new, :destroy]
    
    resources :images,      :only => [:create, :update, :edit, :new, :destroy] do
      member do
        get 'download'
      end
    end
    
    resources :documents,   :only => [:create, :update, :edit, :new, :destroy] do
      member do
        get 'download'
      end
    end    
  end
      
  # Provide an alias for asset paths which are discovered by form helpers such as 
  # commentable, documentable, and imagable controllers
  resources :assets, :path => :inventory do
    resources :comments
    resources :documents
    resources :images
  end
      
  resources :organizations, :path => "org", :only => [:index, :show, :edit, :update] 
  
  resources :comments,    :only => [:create, :update, :edit, :new, :destroy]    
  resources :documents,   :only => [:create, :update, :edit, :new, :destroy] do
    member do
      get 'download'
    end
  end
  resources :images,      :only => [:create, :update, :edit, :new, :destroy] do
    member do
      get 'download'
    end
  end
  
  resources :asset_groups
  resources :general_ledger_accounts
  
  resources :tasks do
    resources :comments
  end
  
  resources :dashboards,    :only => [:index, :show]
  resources :activity_logs, :only => [:index]
  resources :searches,      :only => [:new, :create]
  resources :reports,       :only => [:index, :show] do
    member do
      get 'load'  # load a report using ajax
    end
  end
  
  resources :uploads do
    collection do
      get   'download_file'
      get   'templates'
      post  'create_template'
    end
    member do
      get   'resubmit'
      get   'undo'
      get   'download'
    end
  end 
  
  resources :users do
    collection do
    end
    member do
      post  'set_current_org'
      get   'settings' 
      get   'change_password'
      patch 'update_password'
      get   'profile_photo'
    end
    resources :images
    resources :messages
    
    resources :tasks do
      resources :comments,    :only => [:create, :update, :edit, :new, :destroy]
      collection do
        get   'filter'
      end
      member do
        patch 'update_status'
      end
    end
    # Add user organization filters
    resources :user_organization_filters do
      get 'use'
    end
  end
      
  resources :policies do
    resources :policy_items
    member do
      get   'updater'
      post  'update_assets'
      get   'copy'
      get   'make_current'
    end
  end
  
  resources :notices, :only => [:index, :create, :update, :edit, :new, :destroy] do
    member do
      get 'reactivate'
      get 'deactivate'
    end
  end
  
  # default root for the site -- will be /org/:organization_id/dashboards
  root :to => 'dashboards#index'
  
end
