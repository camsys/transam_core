Rails.application.routes.draw do

  devise_for :users, :controllers => { :sessions => "sessions", :unlocks => "unlocks", :passwords => "passwords" }

  # server static pages
  get "/pages/*id" => 'pages#show', :as => :page, :format => false

  # route errors to the appropriate pages
  %w( 401 403 404 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  # Routes for the issues controller
  resources :issues,    :only => [:create, :update, :edit, :new] do
    member do
      get 'success'
      get 'review'
    end
  end

  resources :vendors do
    collection do
      get 'filter'
    end
  end

  resources :manufacturers, :only => [:index]

  resources :activities

  # Forms are a top-level namespace. All concrete forms must be nested within this
  # controller so they can be protected by the RBAC model
  resources :forms, :only => [:index, :show]

  resources :inventory, :controller => 'assets' do
      collection do
        get 'filter'
        get 'details'
        get 'new_asset'
        get 'export'
        get 'parent'
      end
      member do
        get 'tag'
        get 'summary_info'
        get 'update_status'
        get 'copy'
        get 'add_to_group'
        get 'remove_from_group'
        get 'popup'
      end

    resources :asset_events do 
      member do
        get 'fire_workflow_event'
      end
    end

    resources :tasks,       :only => [:create, :update, :edit, :new, :destroy]
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
    resources :tasks
    resources :comments
    resources :documents
    resources :images
  end

  resources :organizations, :path => "org", :only => [:index, :show, :edit, :update]

  resources :tasks,       :only => [:index, :show, :create, :update, :edit, :new, :destroy] do
    resources :comments
    member do
      get 'fire_workflow_event'
      get 'change_owner'
    end
  end

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

  resources :dashboards,    :only => [:index, :show]
  resources :activity_logs, :only => [:index, :show]

  resources :searches,      :only => [:new, :create] do
    collection do
      post :keyword
      get  :keyword
    end
  end
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
      get   'create_template'
    end
    member do
      get   'undo'
      get   'resubmit'
      get   'download'
    end
  end

  resources :users do
    collection do
      get  'sessions'
    end
    member do
      get   'reset_password'
      get   'settings'
      get   'change_password'
      patch 'update_password'
      get   'profile_photo'
    end

    resources :images

    resources :messages do
      member do
        get 'tag'
        post 'reply'
      end
    end

    resources :tasks do
      resources :comments,    :only => [:create, :update, :edit, :new, :destroy]
      collection do
        get   'filter'
      end
    end
  end

  resources :notifications, only: [:index, :show, :update] do
    collection do
      get 'count'
      get 'read_all'
    end
  end

  resources :policies do
    member do
      get     'get_subtype_minimum_value'
      get     'show_edit_form'
      get     'runner'
      post    'update_assets'
      post    'copy'
      get     'make_current'
      patch   'update_policy_rule'
      post    'update_policy_rule'
      get     'new_policy_rule'
      post    'add_policy_rule'
      delete  'remove_policy_rule'
    end
  end

  resources :notices, :only => [:index, :show, :create, :update, :edit, :new, :destroy] do
    member do
      get 'reactivate'
      get 'deactivate'
    end
  end

  # default root for the site -- will be /org/:organization_id/dashboards
  root :to => 'dashboards#index'

  resources :users, only: [] do
  # Add user organization filters
    resources :user_organization_filters do
      get 'use'
    end
  end

end
