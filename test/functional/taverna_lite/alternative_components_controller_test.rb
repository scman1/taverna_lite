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
  class AlternativeComponentsControllerTest < ActionController::TestCase
    setup do
      @one = taverna_lite_alternative_components(:one)
      @new_ac = taverna_lite_alternative_components(:tl_new_ac)
      @ac_01 = taverna_lite_alternative_components(:tl_alternativecomponent_01)
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
        post :create, alternative_component:{
          alternative_id: @one.alternative_id,
          component_id: @one.component_id,
          note: @one.note
        }
      end

      assert_redirected_to alternative_component_path(assigns(:alternative_component))
    end

    test "should show alternative_component" do
      get :show, id: @ac_01, use_route: :taverna_lite
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @ac_01, use_route: :taverna_lite
      assert_response :success
    end

    test "should update alternative_component" do
      put :update, id: @ac_01, alternative_component: { alternative_id: @ac_01.alternative_id, component_id: @ac_01.component_id, note: @ac_01.note }, use_route: :taverna_lite
      assert_redirected_to alternative_component_path(assigns(:alternative_component))
    end

    test "should destroy alternative_component" do
      assert_difference('AlternativeComponent.count', -1) do
        delete :destroy, id: @ac_01, use_route: :taverna_lite
      end

      assert_redirected_to alternative_components_path
    end
  end
end
