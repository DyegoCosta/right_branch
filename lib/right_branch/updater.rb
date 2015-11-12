require 'octokit'

module RightBranch
  class Updater
    attr_reader :credentials, :repository

    def initialize(options)
      @repository = options[:repository]
      @credentials = options[:credentials]
    end

    def run!(original_pr_number, new_branch)
      new_pr = resubmit_pr(original_pr_number, new_branch)

      update_pr(original_pr_number, state: 'closed')

      comment_on_issue original_pr_number ,
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

    def resubmit_pr(original_pr_number, new_branch)
      original_pr = get_pr(original_pr_number)

      github.create_pull_request \
        repository,
        new_branch,
        original_pr[:head][:label],
        original_pr[:title],
        original_pr[:body]
    end
  end
end
