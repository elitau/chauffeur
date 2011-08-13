module Chauffeur
  module Output
    class Jenkins
      attr_accessor :job_config_list
      
      def initialize(job_config_list)
        @job_config_list = job_config_list
      end
      
      def self.push_config_to_jenkins(job_config)
        name = File.basename(FileUtils.pwd)
        if Jenkins::Api.create_job(name, job_config, options)
          build_url = "#{@uri}/job/#{name.gsub(/\s/,'%20')}/build"
          shell.say "Added#{' ' + template unless template == 'none'} project '#{name}' to Jenkins.", :green
          unless options[:"no-build"]
            shell.say "Triggering initial build..."
            Jenkins::Api.build_job(name)
            shell.say "Trigger additional builds via:"
          else
            shell.say "Trigger builds via:"
          end
          shell.say "  URL: "; shell.say "#{build_url}", :yellow
          shell.say "  CLI: "; shell.say "#{cmd} build #{name}", :yellow
        else
          error "Failed to create project '#{name}'"
        end
      end
      
      def jenkins_server_options
        @config ||= if File.exist?(config_file)
          YAML.parse(File.read(config_file))
        else
          {}
        end
      end

      def config_file
        @config_file ||= Chauffeur.path + 'config/jenkins_config.yml'
      end

      def select_jenkins_server(options)
        unless @uri = Jenkins::Api.setup_base_url(jenkins_server_options)
          error "Either use --host or add remote servers."
        end
        @uri
      end
      
    protected

      def parse_symbol
        shortcut = case @time
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
        
        if shortcut.is_a?(Numeric)
          @time = shortcut
          parse_time
        elsif shortcut
          if @at.is_a?(Time) || (@at.is_a?(Numeric) && @at > 0)
            raise ArgumentError, "You cannot specify an ':at' when using the shortcuts for times."
          else
            return shortcut
          end
        else
          parse_as_string
        end
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

      def comma_separated_timing(frequency, max, start = 0)
        return start     if frequency.blank? || frequency.zero?
        return '*'       if frequency == 1
        return frequency if frequency > (max * 0.5).ceil

        original_start = start

        start += frequency unless (max + 1).modulo(frequency).zero? || start > 0
        output = (start..max).step(frequency).to_a

        max_occurances = (max.to_f  / (frequency.to_f)).round
        max_occurances += 1 if original_start.zero?

        output[0, max_occurances].join(',')
      end
    end
  end
end
