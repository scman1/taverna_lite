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
  class FeatureModelMetadataControllerTest < ActionController::TestCase
    setup do
      @feature_model_metadatum = taverna_lite_feature_model_metadata(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:feature_model_metadata)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create feature_model_metadatum" do
      assert_difference('FeatureModelMetadatum.count') do
        post :create, feature_model_metadatum: { address: @feature_model_metadatum.address, creator: @feature_model_metadatum.creator, date: @feature_model_metadatum.date, department: @feature_model_metadatum.department, description: @feature_model_metadatum.description, email: @feature_model_metadatum.email, feature_model_id: @feature_model_metadatum.feature_model_id, organisation: @feature_model_metadatum.organisation, phone: @feature_model_metadatum.phone, reference: @feature_model_metadatum.reference, website: @feature_model_metadatum.website }
      end

      assert_redirected_to feature_model_metadatum_path(assigns(:feature_model_metadatum))
    end

    test "should show feature_model_metadatum" do
      get :show, id: @feature_model_metadatum
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @feature_model_metadatum
      assert_response :success
    end

    test "should update feature_model_metadatum" do
      put :update, id: @feature_model_metadatum, feature_model_metadatum: { address: @feature_model_metadatum.address, creator: @feature_model_metadatum.creator, date: @feature_model_metadatum.date, department: @feature_model_metadatum.department, description: @feature_model_metadatum.description, email: @feature_model_metadatum.email, feature_model_id: @feature_model_metadatum.feature_model_id, organisation: @feature_model_metadatum.organisation, phone: @feature_model_metadatum.phone, reference: @feature_model_metadatum.reference, website: @feature_model_metadatum.website }
      assert_redirected_to feature_model_metadatum_path(assigns(:feature_model_metadatum))
    end

    test "should destroy feature_model_metadatum" do
      assert_difference('FeatureModelMetadatum.count', -1) do
        delete :destroy, id: @feature_model_metadatum
      end

      assert_redirected_to feature_model_metadata_path
    end
  end
end
