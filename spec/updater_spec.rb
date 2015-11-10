require 'spec_helper'

describe RightBranch::Updater do
  subject { described_class.new default_options }

  let(:default_options) do
    {
      pull_request: '1',
      new_branch: 'test',
      username: 'doge',
      password: 'very_secure',
      repository: 'foo/bar',
    }
  end

  describe '#submit_pr' do
    it 'creats new pull request againts branch' do
      gh = double(:github)
      title, body, label, branch = %w(title body label branch)
      pr = { title: title, body: body, head: { label: label } }

      allow(subject).to receive(:github).and_return(gh)

      expect(gh).to receive(:create_pull_request).with \
        default_options[:repository],
        branch,
        label,
        title,
        body

      subject.send(:submit_pr, pr, branch)
    end
  end
end
