# Copyright (c) 2012-2013 Cardiff University, UK.
# Copyright (c) 2012-2013 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the names of The University of Manchester nor Cardiff University nor
#   the names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Authors
#     Abraham Nieva de la Hidalga
#
# Synopsis
#
# BioVeL Taverna Lite is a prototype interface provided to support the
# inspection and modification of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
require 'test_helper'

module TavernaLite
  class FeatureModelsControllerTest < ActionController::TestCase
    setup do
      @feature_model = taverna_lite_feature_models(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:feature_models)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create feature_model" do
      assert_difference('FeatureModel.count') do
        post :create, :feature_model => { :name => @feature_model.name }
      end

      assert_redirected_to feature_model_path(assigns(:feature_model))
    end

    test "should show feature_model" do
      get :show, :id => @feature_model
      assert_response :success
    end

    test "should get edit" do
      get :edit, :id => @feature_model
      assert_response :success
    end

    test "should update feature_model" do
      put :update, :id => @feature_model, :feature_model => { :name => @feature_model.name }
      assert_redirected_to feature_model_path(assigns(:feature_model))
    end

    test "should destroy feature_model" do
      assert_difference('FeatureModel.count', -1) do
        delete :destroy, :id => @feature_model
      end

      assert_redirected_to feature_models_path
    end
  end
end
