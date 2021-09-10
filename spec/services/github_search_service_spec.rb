require "rails_helper"

describe GithubSearchService do
  describe "#initialize" do
    let(:params) { {"search_term" => "abc def", "repository_name" => "rails/rails"} }
    let(:query) { {q: "abc def in:file repo:rails/rails"} }

    it "should create an instance" do
      gss = GithubSearchService.new(params)

      expect(gss).to be_a_kind_of(GithubSearchService)
      expect(gss.query).to eq query
    end
  end

  describe "#search_code" do
    context "when it succeeds" do
      let(:params) { {"search_term" => "abc", "repository_name" => "rails/rails"} }
      let(:query) { {q: "abc in:file repo:rails/rails"} }
      let(:success_msgs) { {"total_count" => 1, "incomplete_resuls" => false, "items" => ["a lot of hashes"]} }
      let(:response) { double(Faraday::Response, status: 200, body: success_msgs.to_json, success?: true) }
      before do
        allow(Faraday).to receive(:get).with(GithubSearchService::BASE_URI, query,
                                             GithubSearchService::HEADERS).and_return(response)
      end

      it "should send a method call to a class method `get` and returns success messages" do
        results = GithubSearchService.new(params).search_code
        expect(results).to eq success_msgs
      end
    end

    context "when it fails" do
      let(:params) { {"search_term" => "no matches will be returned", "repository_name" => "rails/rails"} }
      let(:query) { {q: "no matches will be returned in:file repo:rails/rails"} }
      let(:error_msgs) do
        {
          "message" => "Validation Failed",
          "errors" => [{"message" => "Must include at least one user, organization, or repository", "resource" => "Search",
                        "field" => "q", "code" => "invalid"}],
          "documentation_url" => "https://developer.github.com/v3/search/"
        }
      end
      let(:response) { double(Faraday::Response, status: 200, body: error_msgs.to_json, success?: true) }
      before do
        allow(Faraday).to receive(:get).with(GithubSearchService::BASE_URI, query,
                                             GithubSearchService::HEADERS).and_return(response)
      end

      it "should send a method call to a class method `get` and trigger an exception" do
        expect do
          GithubSearchService.new(params).search_code
        end.to raise_error(GithubSearchService::RepoNotFoundError)
      end
    end
  end
end
