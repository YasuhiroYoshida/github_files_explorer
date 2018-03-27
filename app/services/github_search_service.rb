class GithubSearchService
  class SearchParamsMissingError < StandardError; end

  include HTTParty

  base_uri 'https://api.github.com/search/code'

  def initialize(search_term, repo)
    raise SearchParamsMissingError unless search_term.present? && repo.present?

    @options = {
      query: "q=#{CGI.escape(search_term)}+in:file+repo:#{CGI.escape(repo)}",
      headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
   }
  end

  def search_code
    self.class.get('', @options)
  end
end
