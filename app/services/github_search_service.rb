class GithubSearchService
  class SearchParamsMissingError < StandardError; end

  include HTTParty

  base_uri 'https://api.github.com/search/code'

  def initialize(search_term, repository_name)
    raise SearchParamsMissingError unless search_term.present? && repository_name.present?

    @options = {
      query: "q=#{CGI.escape(search_term)}+in:file+repo:#{CGI.escape(repository_name)}",
      headers: { 'Accept': 'application/vnd.github.v3.text-match+json', 'User-Agent': 'YasuhiroYoshida' }
   }
  end

  def search_code
    self.class.get('', @options)
  end
end
