require 'rails_helper'

describe GithubSearchService do
  describe '#initialize' do
    context 'when both search term and repository name are missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new(nil, nil) }.to raise_error(GithubSearchService::SearchParamsMissingError)
      end
    end

    context 'when search term is missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new(nil, 'rails/rails') }.to raise_error(GithubSearchService::SearchParamsMissingError)
      end
    end

    context 'when repository name is missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new('abc', nil) }.to raise_error(GithubSearchService::SearchParamsMissingError)
      end
    end

    context 'when both search term and repository name are present' do
      let(:options) {
        {
          query: 'q=abc+in:file+repo:rails%2Frails',
          headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
        }
      }

      it 'should create an instance' do
        gss = GithubSearchService.new('abc', 'rails/rails')

        expect(gss).to be_a_kind_of(GithubSearchService)
        expect(gss.instance_variable_get(:@options)).to eq options
      end
    end

    context 'when both multiple search terms and repository names are present' do
      let(:options) {
        {
          query: 'q=abc+def+in:file+repo:rails%2Frails+sinatra%2Fsinatra',
          headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
        }
      }

      it 'should create an instance with all the spaces properly uri-encoded' do
        gss = GithubSearchService.new('abc def', 'rails/rails sinatra/sinatra')

        expect(gss).to be_a_kind_of(GithubSearchService)
        expect(gss.instance_variable_get(:@options)).to eq options
      end
    end
  end

  describe '#search_code' do
    let(:options) {
      {
        query: 'q=abc+in:file+repo:rails%2Frails',
        headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
      }
    }
    let(:success_msgs) {
      {
        'total_count' => 1, 'incomplete_resuls' => false, 'items' => ['a lot of hashes']
      }
    }
    let(:error_msgs) {
      {
        'message' => 'Validation Failed',
        'errors' => [ { 'message' => 'Must include at least one user, organization, or repository', 'resource' => 'Search', 'field' => 'q', 'code' => 'invalid' } ],
        'documentation_url' => 'https://developer.github.com/v3/search/'
      }.freeze
    }

    context 'when it succeeds' do
      it 'should send a method call to a class method `get` and returns success messages' do
        allow(GithubSearchService).to receive(:get).with('', options).and_return(success_msgs)
        expect(GithubSearchService.new('abc', 'rails/rails').search_code).to eq success_msgs
      end
    end

    context 'when it fails' do
      it 'should send a method call to a class method `get` and trigger an exception' do
        allow(GithubSearchService).to receive(:get).with('', options).and_return(error_msgs)
        expect{ GithubSearchService.new('abc', 'rails/rails').search_code }.to raise_error(GithubSearchService::RepoNotFoundError)
      end
    end
  end
end
