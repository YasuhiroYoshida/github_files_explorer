class GithubSearchService
  class SearchParamsMissingError < StandardError; end
  class RepoNotFoundError < StandardError; end

  include HTTParty

  base_uri 'https://api.github.com/search/code'

  def initialize(search_term, repository_name)
    raise SearchParamsMissingError unless search_term.present? && repository_name.present?

    @options = {
      query: "q=#{CGI.escape(search_term.strip)}+in:file+repo:#{CGI.escape(repository_name.strip)}",
      headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
    }
  end

  def search_code
    results = self.class.get('', @options)
    results.fetch('total_count') { raise RepoNotFoundError }
    results
  end
end
