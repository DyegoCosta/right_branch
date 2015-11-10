require 'spec_helper'
require_relative '../../lib/right_branch/commands/change_pull_request_target'

describe RightBranch::Commands::ChangePullRequestTarget do
  subject { described_class.new(StringIO.new) }

  describe '#run!' do
    let(:updater) { double }

    before do
      allow(subject).to receive(:build_options).and_return({})
    end

    it 'aborts on not found error' do
      allow(updater).to receive(:run!).and_raise \
        ::Octokit::NotFound

      allow(subject).to receive(:updater).and_return updater

      expect { subject.run! }.to raise_error SystemExit,
        'Pull request not found'
    end

    it 'aborts on unauthorized error' do
      allow(updater).to receive(:run!).and_raise \
        ::Octokit::Unauthorized

      allow(subject).to receive(:updater).and_return updater

      expect { subject.run! }.to raise_error SystemExit,
        'Invalid credentials to update pull request'
    end

    it 'aborts on invalid branch error' do
      allow(updater).to receive(:run!).and_raise \
        ::Octokit::UnprocessableEntity

      allow(subject).to receive(:updater).and_return updater

      expect { subject.run! }.to raise_error SystemExit,
        'Invalid branch'
    end
  end

  describe '#missing_required_keys' do
    before do
      stub_const("#{described_class}::REQUIRED_OPTIONS", [:a, :b])
    end

    it 'returns not provided keys' do
      actual = subject.missing_opt_keys b: 'foo'
      expect(actual).to eq([:a])
    end

    it 'returns blank keys' do
      actual = subject.missing_opt_keys a: 'foo', b: ''
      expect(actual).to eq([:b])
    end

    it 'returns empty array if all provided' do
      actual = subject.missing_opt_keys a: 'foo', b: 'bar'
      expect(actual).to eq([])
    end
  end

  describe '#build_options' do
    it 'aborts when keys are missing' do
      allow(subject).to receive(:missing_opt_keys).and_return [:a, :b]
      allow(subject).to receive(:build_opt_parser)
        .and_return double(parse!: true, to_s: 'wow')

      expect { subject.build_options }.to raise_error SystemExit,
        "Missing required options: a, b\n\nwow"
    end
  end
end
