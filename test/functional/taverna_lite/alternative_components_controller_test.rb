require 'test_helper'

module TavernaLite
  class AlternativeComponentsControllerTest < ActionController::TestCase
    setup do
      @alternative_component = taverna_lite_alternative_components(:one)
    end

    test "should get index" do
      get :index, use_route: :taverna_lite
      assert_response :success
      assert_not_nil assigns(:alternative_components)
    end

    test "should get new" do
      get :new, use_route: :taverna_lite
      assert_response :success
    end

    test "should create alternative_component" do
      assert_difference('AlternativeComponent.count') do
        post :create, alternative_component: { alternative_id: @alternative_component.alternative_id, component_id: @alternative_component.component_id, note: @alternative_component.note }
      end

      assert_redirected_to alternative_component_path(assigns(:alternative_component))
    end

    test "should show alternative_component" do
      get :show, id: @alternative_component, use_route: :taverna_lite
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @alternative_component, use_route: :taverna_lite
      assert_response :success
    end

    test "should update alternative_component" do
      put :update, id: @alternative_component, alternative_component: { alternative_id: @alternative_component.alternative_id, component_id: @alternative_component.component_id, note: @alternative_component.note }, use_route: :taverna_lite
      assert_redirected_to alternative_component_path(assigns(:alternative_component))
    end

    test "should destroy alternative_component" do
      assert_difference('AlternativeComponent.count', -1) do
        delete :destroy, id: @alternative_component, use_route: :taverna_lite
      end

      assert_redirected_to alternative_components_path
    end
  end
end
