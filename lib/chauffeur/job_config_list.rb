module Chauffeur
  class JobConfigList
    include Enumerable
    
    def initialize(options)
      @jobs, @env, @set_variables = {}, {}, {}
      
      if options.is_a? String
        options = { :string => options }
      end

      # pre_set(options[:set])
      
      setup = File.read("#{File.expand_path(File.dirname(__FILE__))}/setup.rb")
      schedule = if options[:string]
        options[:string]
      elsif options[:file]
        File.read(options[:file])
      end
      
      instance_eval(setup + schedule, options[:file] || '<eval>')
    end
    
    def every(frequency, options = {})
      @current_time_scope = frequency
      @options = options
      yield
    end
    
    def set(variable, value)
      variable = variable.to_sym
      return if @pre_set_variables[variable]
      
      instance_variable_set("@#{variable}".to_sym, value)
      self.class.send(:attr_reader, variable.to_sym)
      @set_variables[variable] = value
    end
    
    def job_type(name, template)
      class_eval do
        define_method(name) do |task, *args|
          options = { :task => task, :template => template }
          options.merge!(args[0]) if args[0].is_a? Hash
          
          # :output is the newer, more flexible option.
          # options[:output] = @output if defined?(@output) && !options.has_key?(:output)
          
          @jobs[@current_time_scope] ||= []
          @jobs[@current_time_scope] << Chauffeur::Job.new(@current_time_scope, @options.merge(@set_variables).merge(options))
        end
      end
    end
    
    def each_name_and_job_config(&block)
      return if @jobs.empty?
      
      @jobs.each do |time, jobs|
        jobs.each do |job|
          
          
          yield name, create_jenkins_config(job, options)
          
          # Chauffeur::Output::Jenkins.output(time, job) do |cron|
          #   cron << "\n\n"
          #   
          #   if cron.starts_with?("@")
          #     shortcut_jobs << cron
          #   else
          #     regular_jobs << cron
          #   end
          # end
        end
      end

      # shortcut_jobs.join + combine(regular_jobs).join
    end
        
  private
    
    def create_jenkins_config(job, options)
      # template = options[:template] || 'ruby'
      options = {
        :override => true,
      }.merge(options)
      # template = options[:"no-template"] ? 'none' : options[:template]
      job_config = Chauffeur::JenkinsJobConfigBuilder.new(job) do |c|
        
      end
    end
    
    
    #
    # Takes a string like: "variable1=something&variable2=somethingelse"
    # and breaks it into variable/value pairs. Used for setting variables at runtime from the command line.
    # Only works for setting values as strings.
    #
    def pre_set(variable_string = nil)
      return if variable_string.blank?
      
      pairs = variable_string.split('&')
      pairs.each do |pair|
        next unless pair.index('=')
        variable, value = *pair.split('=')
        unless variable.blank? || value.blank?
          variable = variable.strip.to_sym
          set(variable, value.strip)
          @pre_set_variables[variable] = value
        end
      end
    end
  
    def environment_variables
      return if @env.empty?
      
      output = []
      @env.each do |key, val|
        output << "#{key}=#{val.blank? ? '""' : val}\n"
      end
      output << "\n"
      
      output.join
    end
    
    #
    # Takes the standard cron output that Chauffeur generates and finds
    # similar entries that can be combined. For example: If a job should run
    # at 3:02am and 4:02am, instead of creating two jobs this method combines
    # them into one that runs on the 2nd minute at the 3rd and 4th hour.
    #
    def combine(entries)
      entries.map! { |entry| entry.split(/ +/, 6) }
      0.upto(4) do |f|
        (entries.length-1).downto(1) do |i|
          next if entries[i][f] == '*'
          comparison = entries[i][0...f] + entries[i][f+1..-1]
          (i-1).downto(0) do |j|
            next if entries[j][f] == '*'
            if comparison == entries[j][0...f] + entries[j][f+1..-1]
              entries[j][f] += ',' + entries[i][f]
              entries.delete_at(i)
              break
            end
          end
        end
      end

      entries.map { |entry| entry.join(' ') }
    end

  end
end
