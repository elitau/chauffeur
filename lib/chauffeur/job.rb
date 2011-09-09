module Chauffeur
  class Job
    CRON_REGEX = /^.+ .+ .+ .+ .+.?$/
    
    attr_reader :at
    attr_reader :name
    attr_reader :time
    
    def initialize(time, options = {})
      @time    = time
      @options = options
      @name                    = options[:task]
      @at                      = (at = options.delete(:at).is_a?(String)) ? (Chronic.parse(at) || 0) : (at || 0)
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
    
    def time_in_jenkins_syntax
      case @time
        when CRON_REGEX then @time # raw cron sytax given
        # when Symbol then parse_symbol
        # when String then parse_as_string
        else 
          raise 'Not yet implemented'
          # parse_time
      end
    end
    
    def parse_symbol
      shortcut = case @at
        when :reboot   then '@reboot'
        when :year     then 12.months
        when :yearly, 
             :annually then '@annually'
        when :day      then 1.day
        when :daily    then '@daily'
        when :midnight then '@midnight'
        when :month    then 1.month
        when :monthly  then '@monthly'
        when :week     then 1.week
        when :weekly   then '@weekly'
        when :hour     then 1.hour
        when :hourly   then '@hourly'
      end
    end
    
    def parse_as_string
      return unless @time
      string = @time.to_s

      timing = Array.new(4, '*')
      timing[0] = @at.is_a?(Time) ? @at.min  : 0
      timing[1] = @at.is_a?(Time) ? @at.hour : 0

      return (timing << '1-5') * " " if string.downcase.index('weekday')
      return (timing << '6,0') * " " if string.downcase.index('weekend')

      %w(sun mon tue wed thu fri sat).each_with_index do |day, i|
        return (timing << i) * " " if string.downcase.index(day)
      end

      raise ArgumentError, "Couldn't parse: #{@time}"
    end
    
    def parse_time
      timing = Array.new(5, '*')
      case @time
        when 0.seconds...1.minute
          raise ArgumentError, "Time must be in minutes or higher"
        when 1.minute...1.hour
          minute_frequency = @time / 60
          timing[0] = comma_separated_timing(minute_frequency, 59, @at || 0)
        when 1.hour...1.day
          hour_frequency = (@time / 60 / 60).round
          timing[0] = @at.is_a?(Time) ? @at.min : @at
          timing[1] = comma_separated_timing(hour_frequency, 23)
        when 1.day...1.month
          day_frequency = (@time / 24 / 60 / 60).round
          timing[0] = @at.is_a?(Time) ? @at.min  : 0
          timing[1] = @at.is_a?(Time) ? @at.hour : @at
          timing[2] = comma_separated_timing(day_frequency, 31, 1)
        when 1.month..12.months
          month_frequency = (@time / 30  / 24 / 60 / 60).round
          timing[0] = @at.is_a?(Time) ? @at.min  : 0
          timing[1] = @at.is_a?(Time) ? @at.hour : 0
          timing[2] = @at.is_a?(Time) ? @at.day  : (@at.zero? ? 1 : @at)
          timing[3] = comma_separated_timing(month_frequency, 12, 1)
        else
          return parse_as_string
      end
      timing.join(' ')
    end
    
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
    
    def escape_single_quotes(str)
      str.gsub(/'/) { "'\\''" }
    end
    
    def escape_double_quotes(str)
      str.gsub(/"/) { '\"' }
    end
  end
end
