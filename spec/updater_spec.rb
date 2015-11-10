require 'spec_helper'

describe RightBranch::Updater do
  let(:gh) { double(:github) }
  let(:repo) { 'doge/wow' }
  let(:updater) { described_class.new(repository: repo) }

  before { allow(updater).to receive(:github).and_return(gh) }

  describe '#resubmit_pr' do
    it 'creats new pull request againts branch' do
      old_pr_number = 1
      title, body, label, branch = %w(title body label branch)
      pr = { title: 'title', body: 'body', head: { label: 'label' } }
      allow(updater).to receive(:get_pr).with(old_pr_number).and_return(pr)

      expect(gh).to receive(:create_pull_request).with \
        repo, branch, label, title, body

      updater.send(:resubmit_pr, old_pr_number, branch)
    end
  end

  describe '#run!' do
    it 'resubmits old pull request' do
      old = '1'
      branch = 'test'
      allow(updater).to receive(:comment_on_issue)
      allow(updater).to receive(:update_pr)

      expect(updater).to receive(:resubmit_pr)
        .with(old, branch).and_return double(number: '2')

      updater.run!(old, branch)
    end

    it 'closes old pr' do
      old = '1'
      new_pr = double(:new_pr, number: '2')
      allow(updater).to receive(:resubmit_pr).and_return new_pr
      allow(updater).to receive(:comment_on_issue)

      expect(updater).to receive(:update_pr).with \
        old, state: 'closed'

      updater.run!(old, 'testing')
    end

    it 'comment on old pr with new pr number' do
      old = '1'
      new_pr = double(:new_pr, number: '2')
      allow(updater).to receive(:resubmit_pr).and_return new_pr
      allow(updater).to receive(:update_pr)

      allow(updater).to receive(:comment_on_issue).with \
        old, 'Reopened against `testing` (#2)'


      updater.run!(old, 'testing')
    end
  end
end
