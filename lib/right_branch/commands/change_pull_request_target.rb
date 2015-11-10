require 'octokit'
require 'optparse'
require 'highline/import'
require_relative '../updater'

module RightBranch::Commands
  class ChangePullRequestTarget
    REQUIRED_OPTIONS = %i(username repository new_branch pull_request)

    attr_accessor :stream

    def self.run(stream = $stdout)
      new(stream).run!
    end

    def initialize(stream = $stdout)
      @stream = stream
    end

    def run!
      options = build_options
      updater(options).run!
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

      missing = missing_opt_keys(options)
      unless missing.empty?
        abort missing_key_abort_message(missing, opt_parser)
      end

      if String(options[:password]).empty?
        options[:password] = ask("Enter your password: ") { |q| q.echo = '*' }
      end

      options
    end

    def missing_opt_keys(options)
      missing = REQUIRED_OPTIONS - options.keys
      missing += options.select { |_, v| v.empty? }.keys
      missing
    end

    def missing_key_abort_message(keys, opt_parser)
      "Missing required options: #{keys.join(', ')}\n\n#{opt_parser}"
    end

    def updater(options)
      RightBranch::Updater.new(options)
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

        opts.on("--password PASSWORD", "Password") do |v|
          options[:password] = v
        end
      end
    end
  end
end
