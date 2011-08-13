Capistrano::Configuration.instance(:must_exist).load do
  _cset(:chauffeur_roles)        { :db }
  _cset(:chauffeur_command)      { "chauffeur" }
  _cset(:chauffeur_identifier)   { fetch :application }
  _cset(:chauffeur_environment)  { fetch :rails_env, "production" }
  _cset(:chauffeur_update_flags) { "--update-crontab #{fetch :chauffeur_identifier} --set environment=#{fetch :chauffeur_environment}" }
  _cset(:chauffeur_clear_flags)  { "--clear-crontab #{fetch :chauffeur_identifier}" }

  # Disable cron jobs at the begining of a deploy.
  after "deploy:update_code", "chauffeur:clear_crontab"
  # Write the new cron jobs near the end.
  after "deploy:symlink", "chauffeur:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "chauffeur:update_crontab"

  namespace :chauffeur do
    desc <<-DESC
      Update application's crontab entries using chauffeur. You can configure \
      the command used to invoke chauffeur by setting the :chauffeur_command \
      variable, which can be used with Bundler to set the command to \
      "bundle exec chauffeur". You can configure the identifier used by setting \
      the :chauffeur_identifier variable, which defaults to the same value configured \
      for the :application variable. You can configure the environment by setting \
      the :chauffeur_environment variable, which defaults to the same value \
      configured for the :rails_env variable which itself defaults to "production". \
      Finally, you can completely override all arguments to the chauffeur command \
      by setting the :chauffeur_update_flags variable. Additionally you can configure \
      which servers the crontab is updated on by setting the :chauffeur_roles variable.
    DESC
    task :update_crontab do
      options = { :roles => fetch(:chauffeur_roles) }

      if find_servers(options).any?
        on_rollback do
          if fetch :previous_release
            run "cd #{fetch :previous_release} && #{fetch :chauffeur_command} #{fetch :chauffeur_update_flags}", options
          else
            run "cd #{fetch :release_path} && #{fetch :chauffeur_command} #{fetch :chauffeur_clear_flags}", options
          end
        end

        run "cd #{fetch :current_path} && #{fetch :chauffeur_command} #{fetch :chauffeur_update_flags}", options
      end
    end

    desc <<-DESC
      Clear application's crontab entries using chauffeur. You can configure \
      the command used to invoke chauffeur by setting the :chauffeur_command \
      variable, which can be used with Bundler to set the command to \
      "bundle exec chauffeur". You can configure the identifier used by setting \
      the :chauffeur_identifier variable, which defaults to the same value configured \
      for the :application variable. Finally, you can completely override all \
      arguments to the chauffeur command by setting the :chauffeur_clear_flags variable. \
      Additionally you can configure which servers the crontab is cleared on by setting \
      the :chauffeur_roles variable.
    DESC
    task :clear_crontab do
      options = { :roles => chauffeur_roles }
      run "cd #{fetch :release_path} && #{fetch :chauffeur_command} #{fetch :chauffeur_clear_flags}", options if find_servers(options).any?
    end
  end
end
