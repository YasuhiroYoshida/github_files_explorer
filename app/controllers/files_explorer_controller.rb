class FilesExplorerController < ApplicationController
  class SearchParamsMissingError < StandardError; end

  respond_to :html
  before_action :setup, only: [:index]
  before_action :valid_params_present, only: [:index]
  rescue_from SearchParamsMissingError, with: :search_params_missing
  rescue_from GithubSearchService::RepoNotFoundError, with: :repo_not_found

  def index
    if valid_params_present
      findings = GithubSearchService.new(files_explorer_params).search_code
      if findings["total_count"] > 0
        extract_results_and_matched_words_from(findings)
      else
        flash.now[:warning] = "No matching code was found"
      end
    end

    respond_with @results = @results.paginate(params[:page], 5)
  end

  private def extract_results_and_matched_words_from(findings)
    findings["items"].each do |item|
      item["text_matches"].each do |text_match|
        @results.push(
          {
            fragment: text_match["fragment"],
            html_url: item["html_url"],
            file_name: item["path"]
          }
        )
        @matched_words << text_match["matches"].map(&:first).map(&:second)
      end
    end
    @matched_words = @matched_words.flat_map.uniq
  end

  private def setup
    @results = [].paginate(1, 5)
    @matched_words = []
  end

  private def valid_params_present
    return unless params["commit"]
    unless files_explorer_params["search_term"]&.present? && files_explorer_params["repository_name"]&.present?
      raise SearchParamsMissingError
    end

    true
  end

  private def search_params_missing
    flash.now[:danger] = "Enter at least one search term and repository name to get results"
    respond_with @results
  end

  private def repo_not_found
    flash.now[:danger] = "The repository was not found"
    respond_with @results
  end

  private def files_explorer_params
    @files_explorer_params ||= params.permit(:search_term, :repository_name).to_h
  end
end
