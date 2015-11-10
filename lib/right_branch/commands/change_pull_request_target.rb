require 'octokit'
require 'optparse'
require 'highline/import'
require_relative '../updater'

module RightBranch::Commands
  class ChangePullRequestTarget
    REQUIRED_OPTIONS = [:repository, :new_branch, :pull_request]

    attr_accessor :stream

    def self.run(stream = $stdout)
      new(stream).run!
    end

    def initialize(stream = $stdout)
      @stream = stream
    end

    def run!
      options = build_options

      attrs = {
        credentials: build_credentials(options),
        repository: options[:repository]
      }

      updater(attrs).run!(options[:pull_request], options[:new_branch])
    rescue ::Octokit::Unauthorized
      abort 'Invalid credentials to update pull request'
    rescue ::Octokit::UnprocessableEntity
      abort 'Invalid branch'
    rescue ::Octokit::NotFound
      abort 'Pull request not found'
    end

    def build_options
      options = {}
      opt_parser = build_opt_parser(options)
      opt_parser.parse!
      fallback_to_options_from_env(options)

      missing = missing_opt_keys(options)
      unless missing.empty?
        abort missing_key_abort_message(missing, opt_parser)
      end

      if prompt_for_password?(options)
        options[:password] = ask('Enter your password: ') { |q| q.echo = '*' }
      end

      options
    end

    def prompt_for_password?(options)
      String(options[:access_token]).empty? &&
        String(options[:password]).empty?
    end

    def build_credentials(options)
      if options[:access_token].to_s.empty?
        { login: options[:username], password: options[:password] }
      else
        { access_token: options[:access_token] }
      end
    end

    def missing_opt_keys(options)
      missing = REQUIRED_OPTIONS - options.keys
      required_blank = options.select do |k, v|
        REQUIRED_OPTIONS.include?(k) && String(v).empty?
      end
      missing += required_blank.keys
    end

    def missing_key_abort_message(keys, opt_parser)
      "Missing required options: #{keys.join(', ')}\n\n#{opt_parser}"
    end

    def updater(attrs)
      RightBranch::Updater.new(attrs)
    end

    def build_opt_parser(options)
      OptionParser.new do |opts|
        opts.banner = 'Usage: right_branch [options]'

        opts.on("-u", "--username USERNAME", "Username") do |v|
          options[:username] = v
        end

        opts.on("-r", "--repository REPOSITORY", "Repository") do |v|
          options[:repository] = v
        end

        opts.on("-b", "--new-branch NEW_BRANCH", "New branch") do |v|
          options[:new_branch] = v
        end

        opts.on("-p", "--pull-request PULL_REQUEST", "Pull request") do |v|
          options[:pull_request] = v
        end

        opts.on("-t", "--access-token ACCESS_TOKEN", "Access token") do |v|
          options[:access_token] = v
        end

        opts.on("--password PASSWORD", "Password") do |v|
          options[:password] = v
        end
      end
    end

    def fallback_to_options_from_env(options)
      options[:username] ||= ENV['RIGHT_BRANCH_USERNAME']
      options[:repository] ||= ENV['RIGHT_BRANCH_REPOSITORY']
      options[:access_token] ||= ENV['RIGHT_BRANCH_ACCESS_TOKEN']
    end
  end
end
