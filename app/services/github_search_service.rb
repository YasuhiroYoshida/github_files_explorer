class GithubSearchService
  class SearchParamsMissingError < StandardError; end

  class RepoNotFoundError < StandardError; end

  attr_reader :query

  BASE_URI = "https://api.github.com/search/code".freeze
  HEADERS =  {accept: "application/vnd.github.v3.text-match+json"}.freeze

  def initialize(search_term, repository_name)
    raise SearchParamsMissingError unless search_term.present? && repository_name.present?

    @query = {q: "#{search_term.strip} in:file repo:#{repository_name.strip}"}
  end

  def search_code
    response = Faraday.get(BASE_URI, query, HEADERS)
    body = JSON.parse(response.body)
    body.fetch("total_count") { raise RepoNotFoundError }
    body
  end
end
