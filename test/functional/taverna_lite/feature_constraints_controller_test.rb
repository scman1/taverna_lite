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
  class FeatureConstraintsControllerTest < ActionController::TestCase
    setup do
      @feature_constraint = taverna_lite_feature_constraints(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:feature_constraints)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create feature_constraint" do
      assert_difference('FeatureConstraint.count') do
        post :create, feature_constraint: { cnf_clause: @feature_constraint.cnf_clause }
      end

      assert_redirected_to feature_constraint_path(assigns(:feature_constraint))
    end

    test "should show feature_constraint" do
      get :show, id: @feature_constraint
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @feature_constraint
      assert_response :success
    end

    test "should update feature_constraint" do
      put :update, id: @feature_constraint, feature_constraint: { cnf_clause: @feature_constraint.cnf_clause }
      assert_redirected_to feature_constraint_path(assigns(:feature_constraint))
    end

    test "should destroy feature_constraint" do
      assert_difference('FeatureConstraint.count', -1) do
        delete :destroy, id: @feature_constraint
      end

      assert_redirected_to feature_constraints_path
    end
  end
end
