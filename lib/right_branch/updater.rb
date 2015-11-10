require 'octokit'

module RightBranch
  class Updater
    attr_reader :credentials, :repository

    def initialize(options)
      @repository = options[:repository]
      @credentials = options[:credentials]
    end

    def run!(old_pr_number, new_branch)
      new_pr = resubmit_pr(old_pr_number, new_branch)

      update_pr(old_pr_number, state: 'closed')

      comment_on_issue old_pr_number ,
        "Reopened against `#{new_branch}` (##{new_pr.number})"
    end

    private

    def github
      @github ||= Octokit::Client.new(credentials)
    end

    def get_pr(pr_number)
      github.pull_request(repository, pr_number)
    end

    def comment_on_issue(number, comment)
      github.add_comment(repository, number, comment)
    end

    def update_pr(number, args)
      github.update_pull_request(repository, number, args)
    end

    def resubmit_pr(old_pr_number, new_branch)
      old_pr = get_pr(old_pr_number)

      github.create_pull_request \
        repository,
        new_branch,
        old_pr[:head][:label],
        old_pr[:title],
        old_pr[:body]
    end
  end
end
