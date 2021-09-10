class GithubSearchService
  class RepoNotFoundError < StandardError; end

  attr_reader :query

  BASE_URI = "https://api.github.com/search/code".freeze
  HEADERS =  {accept: "application/vnd.github.v3.text-match+json"}.freeze

  def initialize(params)
    @query = {q: "#{params['search_term']&.strip} in:file repo:#{params['repository_name']&.strip}"}
  end

  def search_code
    response = Faraday.get(BASE_URI, query, HEADERS)
    body = JSON.parse(response.body)
    body.fetch("total_count") { raise RepoNotFoundError }
    body
  end
end
