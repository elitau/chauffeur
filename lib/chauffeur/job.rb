module Chauffeur
  class Job
    attr_reader :at
    attr_reader :name
    
    def initialize(options = {})
      @options = options
      @name                    = options[:task]
      @at                      = options.delete(:at)
      @template                = options.delete(:template)
      @job_template            = options.delete(:job_template) || ":job"
      # @options[:output]        = Chauffeur::Output::Redirection.new(options[:output]).to_s if options.has_key?(:output)
      @options[:environment] ||= :production
      @options[:path]        ||= Chauffeur.path
    end
  
    def to_jenkins_config
      job = process_template(@template, @options).strip
      process_template(@job_template, { :job => job }).strip
    end
    
  protected
  
    def process_template(template, options)
      template.gsub(/:\w+/) do |key|
        before_and_after = [$`[-1..-1], $'[0..0]]
        option = options[key.sub(':', '').to_sym]

        if before_and_after.all? { |c| c == "'" }
          escape_single_quotes(option)
        elsif before_and_after.all? { |c| c == '"' }
          escape_double_quotes(option)
        else
          option
        end
      end
    end
    
    # method_option :rubies, :desc          => "run tests against multiple explicit rubies via RVM", :type => :string
    # method_option :"node-labels", :desc   => "run tests against multiple slave nodes by their label (comma separated)"
    # method_option :"assigned-node", :desc => "only use slave nodes with this label (similar to --node-labels)"
    # method_option :"no-build", :desc      => "create job without initial build", :type => :boolean, :default => false
    # method_option :override, :desc        => "override if job exists", :type => :boolean, :default => false
    # method_option :"scm", :desc           => "specific SCM URI", :type => :string
    # method_option :"scm-branches", :desc  => "list of branches to build from (comma separated)", :type => :string, :default => "master"
    # method_option :"public-scm", :desc    => "use public scm URL", :type => :boolean, :default => false
    # method_option :template, :desc        => "template of job steps (available: #{JobConfigBuilder::VALID_JOB_TEMPLATES.join ','})", :default => 'ruby'
    # method_option :"no-template", :desc   => "do not use a template of default steps; avoids Gemfile requirement", :type => :boolean, :default => false
    
    def create_jenkins_config(job_template, options)
      # template = options[:template] || 'ruby'
      options = {:override => true}.merge(options)
      # template = options[:"no-template"] ? 'none' : options[:template]
      job_config = Jenkins::JobConfigBuilder.new do |c|
        c.rubies        = options[:rubies].split(/\s*,\s*/) if options[:rubies]
        c.node_labels   = options[:"node-labels"].split(/\s*,\s*/) if options[:"node-labels"]
        # c.scm           = scm.url
        # c.scm_branches  = options[:"scm-branches"].split(/\s*,\s*/)
        c.assigned_node = options[:"assigned-node"] if options[:"assigned-node"]
        c.public_scm    = options[:"public-scm"]
      end
    end
    
    def escape_single_quotes(str)
      str.gsub(/'/) { "'\\''" }
    end
    
    def escape_double_quotes(str)
      str.gsub(/"/) { '\"' }
    end
  end
end
