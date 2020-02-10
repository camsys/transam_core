Rails.application.routes.draw do

  devise_for :users, :controllers => { :sessions => "sessions", :unlocks => "unlocks", :passwords => "passwords" }

  resources :transam_workflow, only: [] do
    collection do
      get :fire_workflow_event
      post :fire_workflow_events
    end
  end

  # JSON API #
  namespace :api do
    get 'touch_session' => "api#touch_session"
    namespace :v1 do
      post 'sign_in' => 'sessions#create'
      delete 'sign_out' => 'sessions#destroy'

      resources :users, only: [:index] do 
        resources :images
        
        collection do 
          get :profile
        end
      end

      resources :assets, only: [:show, :index] do
        collection do
          post :filter
        end
        resources :images
        resources :documents
      end

      resources :query_fields, only: [:index]
      resources :query_categories, only: [:index]
      resources :organizations, only: [:show, :index] do 
      end
    end
  end
  
  # server static pages
  get "/pages/*id" => 'pages#show', :as => :page, :format => false

  # route errors to the appropriate pages
  %w( 401 403 404 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  #-----------------------------------------------------------------------------
  # Landing page for checking the health of the system, used mostly as a heartbeat
  # checker for the system overall
  #-----------------------------------------------------------------------------
  get 'system_health_check', to: 'errors#system_health'


  get "client_admin" => 'client_admin#index'

  resources :system_configs, only: [:show, :edit, :update] do
    member do
      get 'fiscal_year_rollover'
    end
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
        post 'fire_asset_event_workflow_events'
        get 'get_summary'
        get 'inventory_index'
      end

      member do
        get 'tag'
        get 'summary_info'
        get 'update_status'
        get 'copy'
        get 'add_to_group'
        get 'remove_from_group'
        get 'popup'
        get 'get_subheader'
        get 'get_dependents'
        patch 'add_dependents'
        get 'get_dependent_subform'
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

  resources :asset_events, :only => [] do
    collection do
      get 'get_summary'
      get 'popup'
    end
  end

  resources :transam_assets, :controller => 'assets', :only => [] do
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

  resources :organizations, :path => "org" do
    collection do
      get 'get_policies'
    end
  end

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
  resources :images do
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
      get  :reset
    end
  end

  resources :saved_searches do
    member do
      get 'reorder'
    end
  end

  resources :saved_queries do
    collection do
      post 'query'
      get 'export_unsaved'
      get 'save_as'
    end

    member do 
      get 'export'
      post 'clone'
      get 'show_remove_form'
      post 'remove_from_orgs'
    end
  end

  resources :query_fields, only: [:index]
  resources :query_filters, only: [] do 
    collection do 
      get 'manufacturers'
      get 'manufacturer_models'
      get 'vendors'
      get 'locations'
      get 'parents'
    end
  end
  get 'render_new', to: 'query_filters#render_new', as: :load_new_query_filter

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

  resources :message_templates do 
    collection do 
      get 'message_history'
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
      get 'authorizations'
      get 'popup'
    end

    resources :user_organization_filters do
      get 'use'
      post 'set_org'
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

  resources :rule_sets

  resources :policies do
    member do
      get     'check_subtype_rule_exists'
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
      get     'inherit'
      post     'distribute'
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

end
