require "chauffeur/version"

module Chauffeur
  autoload :JobConfigList, 'chauffeur/job_config_list'
  autoload :Job,           'chauffeur/job'
  autoload :CommandLine,   'chauffeur/command_line'
  
  # module Output
  #   autoload :Cron,        'chauffeur/cron'
  #   autoload :Redirection, 'chauffeur/output_redirection'
  # end
  
  def self.job_cofigurations(options)
    Chauffeur::JobConfigList.new(options)
  end
  
  def self.rails3?
    File.exists?(File.join(path, 'script', 'rails'))
  end

  def self.bundler?
    File.exists?(File.join(path, 'Gemfile'))
  end
  
  def self.path
    Pathname.new(Dir.pwd)
  end
  
end
