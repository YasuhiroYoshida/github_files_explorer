class FilesExplorerController < ApplicationController
  respond_to :html
  before_action :setup, only: [:index]
  rescue_from GithubSearchService::SearchParamsMissingError, with: :search_params_missing
  rescue_from GithubSearchService::RepoNotFoundError, with: :repo_not_found

  def index
    if files_explorer_params['search_term']&.present? && files_explorer_params['repository_name']&.present?
      findings = GithubSearchService.new(files_explorer_params['search_term'], files_explorer_params['repository_name']).search_code
      if findings['total_count'] > 0
        findings['items'].each do |item|
          item['text_matches'].each do |text_match|
            @results.push(
              {
                fragment: text_match['fragment'],
                html_url: item['html_url'],
                file_name: item['path']
              }
            )
            @matched_words << text_match['matches'].map(&:first).map(&:second)
          end
          @matched_words.flatten.uniq!
        end
      else
        flash.now[:warning] = 'No matching code was found'
      end
    else
      flash.now[:info] = 'Enter a search term and repository name'
    end

    respond_with @results = @results.paginate(params[:page], 5)
  end

  private

    def setup
      @results = [].paginate(1, 5)
      @matched_words = []
    end

    def search_params_missing
      flash.now[:danger] = 'Enter at least one search term and repository name to get results'
      respond_with @results
    end

    def repo_not_found
      flash.now[:danger] = 'The repository was not found'
      respond_with @results
    end

    def files_explorer_params
      params.permit(:search_term, :repository_name)
    end
end
