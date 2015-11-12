require 'spec_helper'

describe RightBranch::Updater do
  let(:gh) { double(:github) }
  let(:repo) { 'doge/wow' }
  let(:updater) { described_class.new(repository: repo) }

  before { allow(updater).to receive(:github).and_return(gh) }

  describe '#resubmit_pr' do
    it 'creats new pull request againts branch' do
      original_pr_number = 1
      title, body, label, branch = %w(title body label branch)
      pr = { title: 'title', body: 'body', head: { label: 'label' } }
      allow(updater).to receive(:get_pr).with(original_pr_number).and_return(pr)

      expect(gh).to receive(:create_pull_request).with \
        repo, branch, label, title, body

      updater.send(:resubmit_pr, original_pr_number, branch)
    end
  end

  describe '#run!' do
    it 'resubmits original pull request' do
      original = '1'
      branch = 'test'
      allow(updater).to receive(:comment_on_issue)
      allow(updater).to receive(:update_pr)

      expect(updater).to receive(:resubmit_pr)
        .with(original, branch).and_return double(number: '2')

      updater.run!(original, branch)
    end

    it 'closes original pr' do
      original = '1'
      new_pr = double(:new_pr, number: '2')
      allow(updater).to receive(:resubmit_pr).and_return new_pr
      allow(updater).to receive(:comment_on_issue)

      expect(updater).to receive(:update_pr).with \
        original, state: 'closed'

      updater.run!(original, 'testing')
    end

    it 'comment on original pr with new pr number' do
      original = '1'
      new_pr = double(:new_pr, number: '2')
      allow(updater).to receive(:resubmit_pr).and_return new_pr
      allow(updater).to receive(:update_pr)

      allow(updater).to receive(:comment_on_issue).with \
        original, 'Reopened against `testing` (#2)'


      updater.run!(original, 'testing')
    end
  end
end
