require 'rails_helper'

include Shoulda::Matchers::ActionController

RSpec.describe 'GithubFilesExplorer' do
  context 'when params do not satisfy the search requirements' do
    context 'with no search term and no repository name (default)' do
      it 'should return no results' do
        get '/', params: { search_term: '', repository_name: ''}

        expect(response).to be_success
        expect(assigns(:results)).to be_a(Array).and be_empty
        expect(assigns(:matched_words)).to be_a(Array).and be_empty
        expect(controller).to set_flash.now[:info].to(/Enter a search term and repository name/)
      end
    end

    context 'with one search term and no repository name' do
      it 'should return no results' do
        get '/', params: { search_term: 'abc', repository_name: ''}

        expect(response).to be_success
        expect(assigns(:results)).to be_a(Array).and be_empty
        expect(assigns(:matched_words)).to be_a(Array).and be_empty
        expect(controller).to set_flash.now[:info].to(/Enter a search term and repository name/)
      end
    end

    context 'with one search term and one repository name' do
      it 'should return no results' do
        get '/', params: { search_term: '', repository_name: 'rails/rails'}

        expect(response).to be_success
        expect(assigns(:results)).to be_a(Array).and be_empty
        expect(assigns(:matched_words)).to be_a(Array).and be_empty
        expect(controller).to set_flash.now[:info].to(/Enter a search term and repository name/)
      end
    end
  end

  context 'when params satisfy the search requirements' do
    context 'but the repository was not found' do
      it 'should return no results' do
        get '/', params: { search_term: 'alias_method', repository_name: 'rails/railsssss'}

        expect(response).to be_success
        expect(assigns(:results)).to be_a(Array).and be_empty
        expect(assigns(:matched_words)).to be_a(Array).and be_empty
        expect(controller).to set_flash.now[:danger].to(/The repository was not found/)
      end
    end

    context 'but no matching code was found' do
      it 'should return no results' do
        get '/', params: { search_term: '%$^$&%*^&()**^&^%', repository_name: 'rails/rails'}

        expect(response).to be_success
        expect(assigns(:results)).to be_a(Array).and be_empty
        expect(assigns(:matched_words)).to be_a(Array).and be_empty
        expect(controller).to set_flash.now[:warning].to(/No matching code was found/)
      end
    end

    context 'and both the repository and matching code were found' do
      it 'should return results' do
        get '/', params: { search_term: 'alias_method', repository_name: 'rails/rails'}

        expect(response).to be_success
        expect(assigns(:results)).to be_a(Array).and be_present
        expect(assigns(:results).first.key?(:fragment)).to be_truthy
        expect(assigns(:results).first[:fragment]).to match(/alias_method/)
        expect(assigns(:results).first.key?(:html_url)).to be_truthy
        expect(assigns(:results).first[:html_url]).to match(/https\:\/\/github.com\//)
        expect(assigns(:results).first.key?(:file_name)).to be_truthy
        expect(assigns(:results).first[:file_name]).to be_present
        expect(controller).not_to set_flash.now[:info]
      end
    end
  end
end
