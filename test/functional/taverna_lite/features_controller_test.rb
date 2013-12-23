require 'test_helper'

module TavernaLite
  class FeaturesControllerTest < ActionController::TestCase
    setup do
      @feature = features(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:features)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create feature" do
      assert_difference('Feature.count') do
        post :create, feature: { cardinality_lower_bound: @feature.cardinality_lower_bound, cardinality_upper_bound: @feature.cardinality_upper_bound, component_id: @feature.component_id, feature_model_id: @feature.feature_model_id, feature_type_id: @feature.feature_type_id, name: @feature.name, parent_node_id: @feature.parent_node_id }
      end

      assert_redirected_to feature_path(assigns(:feature))
    end

    test "should show feature" do
      get :show, id: @feature
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @feature
      assert_response :success
    end

    test "should update feature" do
      put :update, id: @feature, feature: { cardinality_lower_bound: @feature.cardinality_lower_bound, cardinality_upper_bound: @feature.cardinality_upper_bound, component_id: @feature.component_id, feature_model_id: @feature.feature_model_id, feature_type_id: @feature.feature_type_id, name: @feature.name, parent_node_id: @feature.parent_node_id }
      assert_redirected_to feature_path(assigns(:feature))
    end

    test "should destroy feature" do
      assert_difference('Feature.count', -1) do
        delete :destroy, id: @feature
      end

      assert_redirected_to features_path
    end
  end
end
