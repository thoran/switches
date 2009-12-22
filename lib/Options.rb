class Options
  
  class << self
    attr_accessor :interpreted_action, :project_path, :dbms, :dbms_host, :dbms_username, :dbms_password, :svn_uri, :svn_username, :svn_password, :verbosity, :rails_version, :project_name, :app_root, :use_edge
  end
  
  def self.set
    # This is checked first so as the subsequent dialogues honour these settings.  It has a default of nil.  
    set_verbosity
    
    unless Options.verbosity == 'silent' || interpreted_action && project_path && dbms && dbms_host && dbms_username && dbms_password && svn_uri && svn_username && svn_password && rails_version
      puts '', 'Please enter the following...'
    end
    
    #pp @interpreted_action
    set_action unless @interpreted_action
    set_project_path unless @project_path
    
    set_dbms unless @dbms
    set_dbms_host unless @dbms_host
    set_dbms_username unless @dbms_username
    # This is here so as the password dialogue happens next to the username dialogue.  It has a default of nil.  
    set_dbms_password
    
    set_svn_uri unless @svn_uri
    set_svn_username unless @svn_username
    # This is here so as the password dialogue happens next to the username dialogue.  It has a default of nil.  
    set_svn_password
    
    set_rails_version if !@rails_version && (@interpreted_action == :create_app || @interpreted_action == :create_all)
    
    # The following are derived options and as such don't need to be checked if set.  
    set_use_edge unless (@interpreted_action != :create_app || @interpreted_action != :create_all) # @use_edge is derived from @rails_version.  
    set_project_name # @project_name is derived from @project_path.  
    set_app_root # @app_root is derived from @project_path.  
  end
  
  def self.set_action(given_action = nil)
    @interpreted_action = (
      given_action ? (
        interpret_given_action(given_action)
      ) : ( # This will only get seen if neither the action, nor the project path is entered.  
        (Options.verbosity == 'silent') ?
          Options.interpret_given_action('create') :
          CLI.get_action
      )
    )
  end
  
  def self.interpret_given_action(given_action)
    case given_action
      when 'create', 'new', 'make', 'install'
        :create_app
      when 'destroy', 'delete', 'remove', 'rm', 'unmake', 'deinstall', 'remove_app', 'remove-app', 'un_make', 'un-make', 'de_install', 'de-install'
        :destroy_app
      when 'create_databases', 'create_dbs', 'new_databases', 'new_dbs', 'new_db', 'create_db', 'create-databases', 'create-dbs', 'new-databases', 'new-dbs', 'new-db', 'create-db'
        :create_databases
      when 'drop_databases', 'drop_dbs', 'destroy_databases', 'destroy_dbs', 'delete_databases', 'delete_dbs', 'remove_databases', 'rm_dbs', 'rm_databases', 'rm_dbs', 'delete_db', 'rm_db', 'drop', 'drop-databases', 'drop-dbs', 'destroy-databases', 'destroy-dbs', 'delete-databases', 'delete-dbs', 'remove-databases', 'rm-dbs', 'rm-databases', 'rm-dbs', 'delete-db', 'rm-db'
        :drop_databases
      when 'create_all', 'new_all', 'make_all', 'install_all', 'create-all', 'new-all', 'make-all', 'install-all'
        :create_all
      when 'destroy_all', 'delete_all', 'remove_all', 'rm_all', 'unmake_all', 'deinstall_all', 'destroy-all', 'delete-all', 'remove-all', 'rm-all', 'unmake-all', 'deinstall-all'
        :destroy_all
      when 'create_repository', 'create_repo', 'new_repository', 'new_repo', 'create-repository', 'create-repo', 'new-repository', 'new-repo'
        :create_repository
      when 'delete_repository', 'delete_repo', 'remove_repository', 'remove_repo', 'rm_repository', 'rm_repo', 'destroy_repository', 'destroy_repo', 'delete-repository', 'delete-repo', 'remove-repository', 'remove-repo', 'rm-repository', 'rm-repo', 'destroy-repository', 'destroy-repo'
        :destroy_repository
      else
        puts 'Unknown action.'
        exit
    end # case
  end # def interpret_given_action
  
  def self.set_project_path(project_path = nil)
    @project_path = (
      project_path ? (
        project_path
      ) : (
        Options.verbosity == 'silent' ?
          (puts 'As a minimum a project path is required when verbosity is set to silent.'; exit) :
          CLI.get_project_path
      )
    )
  end
  
  def self.set_dbms
    @dbms = (
      @dbms ? (
        @dbms
      ) : (
        Options.verbosity == 'silent' ?
          'mysql' :
          CLI.get_dbms
      )
    )
  end
  
  def self.set_dbms_host
    @dbms_host = (
      @dbms_host ? (
        @dbms_host
      ) : (
        Options.verbosity == 'silent' ?
          'localhost' :
          CLI.get_dbms_host
      )
    )
  end
  
  def self.set_dbms_username
    @dbms_username = (
      @dbms_username ? (
        @dbms_username
      ) : (
        Options.verbosity == 'silent' ?
          'root' :
          CLI.get_dbms_username
      )
    )
  end
  
  def self.set_dbms_password
    @dbms_password = (
      @dbms_password ? (
        @dbms_password
      ) : (
        Options.verbosity == 'silent' ?
          '' :
          CLI.get_dbms_password
      )
    )
  end
  
  def self.set_svn_uri
    @svn_uri = (
      @svn_uri ? (
        @svn_uri
      ) : (
        Options.verbosity == 'silent' ?
          'localhost' :
          CLI.get_svn_uri
      )
    )
  end
  
  def self.set_svn_username
    @svn_username = (
      @svn_username ? (
        @svn_username
      ) : (
        Options.verbosity == 'silent' ?
          'root' :
          CLI.get_svn_username
      )
    )
  end
  
  def self.set_svn_password
    @svn_password = (
      @svn_password ? (
        @svn_password
      ) : (
        Options.verbosity == 'silent' ?
          '' :
          CLI.get_svn_password
      )
    )
  end
  
  def self.set_rails_version
    unless [:destroy_all, :create_databases, :drop_databases].include?(@interpreted_action)
      @rails_version = (
        @rails_version ? (
          @rails_version
        ) : (
          Options.verbosity == 'silent' ?
            'default' :
            CLI.get_rails_version
        )
      )
    end # unless
  end # def self.set_rails_version
  
  def self.set_verbosity
    case @verbosity
      when nil
        @verbosity = 'normal'
    end
  end
  
  def self.set_use_edge
    @use_edge = (@rails_version == 'edge' ? true : false)
  end
  
  def self.set_project_name
    @project_name = File.basename(@project_path)
  end
    
  def self.set_app_root
    @app_root = $APP_ROOT = File.expand_path(@project_path)
  end
    
end
