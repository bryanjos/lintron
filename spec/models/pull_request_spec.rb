require 'rails_helper'

describe PullRequest do
  let(:pr) do
    pr = PullRequest.new(org: 'test-org', repo: 'test', pr_number: 123)
    mock_commit = OpenStruct.new sha: 'deadbeef'
    allow(pr).to receive(:latest_commit).and_return mock_commit
    pr
  end

  describe '#from_url' do
    it 'can parse the URL correctly' do
      pr = PullRequest.from_url('https://github.com/test-org/test/pull/123')

      expect(pr.org).to eq 'test-org'
      expect(pr.repo).to eq 'test'
      expect(pr.pr_number).to eq 123
    end
  end

  describe '#from_payload' do
    it 'can handle a GitHub payload' do
      pr = PullRequest.from_payload(
        'pull_request' => {
          'head' => {
            'repo' => {
              'name' => 'test',
              'owner' => {
                'login' => 'test-org',
              },
            },
          },
        },
        'number' => 123,
      )

      expect(pr.org).to eq 'test-org'
      expect(pr.repo).to eq 'test'
      expect(pr.pr_number).to eq 123
    end
  end

  describe '#expected_url_from_path' do
    it 'returns a github url with the correct parts' do
      expect do
        url = pr.expected_url_from_path('spec/models/post_spec.rb')
        expect(url).to include 'deadbeef' # sha
        expect(url).to include 'post_spec.rb' # filename
      end.to_not raise_error
    end
  end

  describe '#get_config_file' do
    let(:linter_config_file) { LinterConfigFile.from_content('configs in here') }

    it 'returns a linter config file if it exists' do
      allow(pr).to receive(:fetch_config_file).and_return(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
    end

    it 'returns nil on a NotFound error' do
      contents_client = Github.repos.contents
      allow(Github.repos.contents).to receive(:get).and_throw(Github::Error::NotFound)
      VCR.use_cassette('return_nil_on_not_found') do
        expect do
          expect(pr.get_config_file('.eslintrc')).to be(nil)
        end.not_to raise_error
      end
    end

    it 'does not try to fetch nil config file from github' do
      expect(Github.repos.contents).to_not receive(:get)
      expect do
        expect(pr.get_config_file(nil)).to be(nil)
      end.not_to raise_error
    end

    it 'only fetches once for repeated access to a config file' do
      allow(pr).to receive(:fetch_config_file).once.and_return(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
      expect(pr.get_config_file('.eslintrc')).to be(linter_config_file)
    end

    it 'only fetches once if the config is not found' do
      allow(pr).to receive(:fetch_config_file).once.and_return(nil)
      expect do
        expect(pr.get_config_file('.eslintrc')).to be(nil)
        expect(pr.get_config_file('.eslintrc')).to be(nil)
        expect(pr.get_config_file('.eslintrc')).to be(nil)
      end.not_to raise_error
    end
  end
end
