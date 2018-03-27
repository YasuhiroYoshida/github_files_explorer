class FilesExplorerController < ApplicationController
  respond_to :html
  before_action :setup, only: [:index]
  rescue_from GithubSearchService::SearchParamsMissingError, with: :search_params_missing

  def index
    if params['search_term']&.present? && params['repo']&.present?
      findings = GithubSearchService.new(params['search_term'], params['repo']).search_code
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
        flash.now[:warning] = "No matching code was found"
      end
    else
      flash.now[:info] = "Enter a search term and repo"
    end

    respond_with @results = @results.paginate(params[:page], 3)
  end

  private

    def setup
      @results = [].paginate(1, 3)
      @matched_words = []
    end

    def search_params_missing
      flash.now[:danger] = "Enter at least one search term and repo to get results"
      respond_with @results
    end
end
