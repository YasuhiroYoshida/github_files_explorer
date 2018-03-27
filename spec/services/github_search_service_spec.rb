require "rails_helper"

describe GithubSearchService do
  let(:options) {
    {
      query: 'q=ab+cde+in:file+repo:rails%2Frails',
      headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
    }
  }

  describe '#initialize' do
    context 'when search term is missing' do
      it 'should trigger exception' do
        expect{ GithubSearchService.new(nil, 'rails/rails') }.to raise_error(GithubSearchService::SearchTermMissingError)
      end
    end

    context 'when search term is present' do
      it 'should create an instance' do
        gss = GithubSearchService.new('ab cde', 'rails/rails')

        expect(gss).to be_a_kind_of(GithubSearchService)
        expect(gss.instance_variable_get(:@options)).to eq options
      end
    end
  end

  describe '#search_code' do
    it 'should receive a class method call `get`' do
      allow(GithubSearchService).to receive(:get).with('', options).and_return( { 'total_count': 1, 'incomplete_resuls': false, 'items': [] } )
      GithubSearchService.new('ab cde', 'rails/rails').search_code
    end
  end
end
