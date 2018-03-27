require "rails_helper"

describe GithubSearchService do
  describe '#initialize' do
    context 'when both search term and repo are missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new(nil, nil) }.to raise_error(GithubSearchService::SearchParamsMissingError)
      end
    end

    context 'when search term is missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new(nil, 'rails/rails') }.to raise_error(GithubSearchService::SearchParamsMissingError)
      end
    end

    context 'when repo is missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new('abc', nil) }.to raise_error(GithubSearchService::SearchParamsMissingError)
      end
    end

    context 'when both search term and repo are present' do
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

    context 'when both multiple search terms and repos are present' do
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

    it 'should receive a class method call `get`' do
      allow(GithubSearchService).to receive(:get).with('', options).and_return( { 'total_count': 1, 'incomplete_resuls': false, 'items': [] } )
      GithubSearchService.new('abc', 'rails/rails').search_code
    end
  end
end
