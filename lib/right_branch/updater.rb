require 'octokit'

module RightBranch
  class Updater
    attr_reader :username, :password, :pull_request,
      :new_branch, :repository

    def initialize(options)
      @username = options.fetch(:username)
      @password = options.fetch(:password)
      @pull_request = options.fetch(:pull_request)
      @new_branch = options.fetch(:new_branch)
      @repository = options.fetch(:repository)
    end

    def run
      old_pr = get_pr(pull_request)
      new_pr = submit_pr(old_pr, new_branch)
      update_pr(old_pr[:number], state: 'closed')
      comment_on_issue old_pr[:number] ,
        "Reopened against `#{new_branch}` (##{new_pr.number})"
    end

    private

    def github
      @github ||= Octokit::Client.new(login: username, password: password)
    end

    def get_pr(pr)
      github.pull_request(repository, pr)
    end

    def comment_on_issue(number, comment)
      github.add_comment(repository, number, comment)
    end

    def update_pr(number, args)
      github.update_pull_request(repository, number, args)
    end

    def submit_pr(pr, new_branch)
      github.create_pull_request \
        repository,
        new_branch,
        pr[:head][:label],
        pr[:title],
        pr[:body]
    end
  end
end
