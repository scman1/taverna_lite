require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  fixtures :all
  setup do
    @workflow = workflows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflows)
  end

#  test "should get new" do
#    get :new
#    assert_response :success
#  end

#  test "should create workflow" do
#    assert_difference('Workflow.count') do
#      post :create, workflow: { author: @workflow.author, description: @workflow.description, is_shared: @workflow.is_shared, my_experiment_id: @workflow.my_experiment_id, name: @workflow.name, title: @workflow.title, user_id: @workflow.user_id, workflow_file: @workflow.workflow_file }
#    end

#    assert_redirected_to workflow_path(assigns(:workflow))
#  end

#  test "should show workflow" do
#    get :show, id: @workflow
#    assert_response :success
#  end

#  test "should get edit" do
#    get :edit, id: @workflow
#    assert_response :success
#  end

#  test "should update workflow" do
#    put :update, id: @workflow, workflow: { author: @workflow.author, description: @workflow.description, is_shared: @workflow.is_shared, my_experiment_id: @workflow.my_experiment_id, name: @workflow.name, title: @workflow.title, user_id: @workflow.user_id, workflow_file: @workflow.workflow_file }
#    assert_redirected_to workflow_path(assigns(:workflow))
#  end

#  test "should destroy workflow" do
#    assert_difference('Workflow.count', -1) do
#      delete :destroy, id: @workflow
#    end

#    assert_redirected_to workflows_path
#  end
end
