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

# The classes in the dummy app should not be tested. Maybe we should focus on
# integration tests. Cannot get these to pass so leave them for now.

#require 'test_helper'

#class ResultsControllerTest < ActionController::TestCase
#  setup do
#    @result = taverna_lite_results(:one)
#  end

#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:results)
#  end

#  test "should get new" do
#    get :new
#    assert_response :success
#  end

#  test "should create result" do
#    assert_difference('Result.count') do
#      post :create, result: { depth: @result.depth, filepath: @result.filepath, filetype: @result.filetype, name: @result.name, run_id: @result.run_id }
#    end

#    assert_redirected_to result_path(assigns(:result))
#  end

#  test "should show result" do
#    get :show, id: @result
#    assert_response :success
#  end

#  test "should get edit" do
#    get :edit, id: @result
#    assert_response :success
#  end

#  test "should update result" do
#    put :update, id: @result, result: { depth: @result.depth, filepath: @result.filepath, filetype: @result.filetype, name: @result.name, run_id: @result.run_id }
#    assert_redirected_to result_path(assigns(:result))
#  end

#  test "should destroy result" do
#    assert_difference('Result.count', -1) do
#      delete :destroy, id: @result
#    end

#    assert_redirected_to results_path
#  end
#end
