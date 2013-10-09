require 'test_helper'

module TavernaLite
  class WorkflowComponentsControllerTest < ActionController::TestCase
    setup do
      @workflow_component = taverna_lite_workflow_components(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:workflow_components)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create workflow_component" do
      assert_difference('WorkflowComponent.count') do
        post :create, workflow_component: { family: @workflow_component.family, license_id: @workflow_component.license_id, name: @workflow_component.name, registry: @workflow_component.registry, version: @workflow_component.version, workflow_id: @workflow_component.workflow_id }
      end

      assert_redirected_to workflow_component_path(assigns(:workflow_component))
    end

    test "should show workflow_component" do
      get :show, id: @workflow_component
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @workflow_component
      assert_response :success
    end

    test "should update workflow_component" do
      put :update, id: @workflow_component, workflow_component: { family: @workflow_component.family, license_id: @workflow_component.license_id, name: @workflow_component.name, registry: @workflow_component.registry, version: @workflow_component.version, workflow_id: @workflow_component.workflow_id }
      assert_redirected_to workflow_component_path(assigns(:workflow_component))
    end

    test "should destroy workflow_component" do
      assert_difference('WorkflowComponent.count', -1) do
        delete :destroy, id: @workflow_component
      end

      assert_redirected_to workflow_components_path
    end
  end
end
