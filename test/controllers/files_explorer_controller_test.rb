require 'test_helper'

class FilesExplorerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get files_explorer_index_url
    assert_response :success
  end

end
