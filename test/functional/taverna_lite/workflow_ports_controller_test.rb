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
  class WorkflowPortsControllerTest < ActionController::TestCase
    setup do
      @workflow_port = taverna_lite_workflow_ports(:one)
    end
    test "just test put" do
      # test using this hash
      # {"workflow_id"=>"1", "selected_tab"=>"components",
      #  "selected_choice"=>"inputs", "file_uploads"=>{"name_for_name"=>"name",
      #  "description_for_name"=>"The name for greeting string",
      #  "name"=>"Dorothy!", "type_for_name"=>"1", "display_for_name"=>"1"},
      #  "commit"=>"Save", "id"=>"1"}
      # try 01: breaks after ["utf8"=>"✓",], remove and retry
      # try 02: forgot to change id to 1, change and retry
      # try 03: successful, will try removing non essential vars,
      #         start with autenticity token and retry
      # try 04: successful, all remaining vars are used in the method so will
      #         leave as it is for now
      put :save_custom_inputs, {"workflow_id"=>"1","selected_tab"=>"components",
        "selected_choice"=>"inputs", "file_uploads"=>{"name_for_name"=>"name",
        "description_for_name"=>"Your name for the greeting",
        "name"=>"World!", "type_for_name"=>"1", "display_for_name"=>"1"},
        "commit"=>"Save", "id"=>"1"}
      assert_redirected_to edit_workflow_profile_path(1)
    end

    test "should not update workflow_port if no changes" do
      old_port = @workflow_port
      # problem 1: Needs to have a valid workflow even if the workflow is not
      #            part of taverna_lite
      # solution:  Add the workflow fixture at test/fixtures not in dummy and
      #            not in test/fixtures/taverna_lite
      # problem 2: profile reads from a workflow file so need an actual workflow
      #            file for tests
      # solution:  Specify workflow id and add workflow file to that id on dummy
      #            workflows path under specified id
      # problem 3: the parameters are not being passed correctly so the method
      #            is not actually working.
      # solution:  test only using put to see if it works OK, then fix put
      put :save_custom_inputs, {"workflow_id"=>@workflow_port.workflow_id,
        "selected_tab"=>"components", "selected_choice"=>"inputs",
        "file_uploads"=>{"name_for_name"=>@workflow_port.name,
        "description_for_name"=>@workflow_port.description,
        @workflow_port.name => @workflow_port.example, "display_for_name"=>"1"},
        "commit"=>"Save", "id"=>@workflow_port.workflow_id}
      # problem 4: by default redirecting to the edit path, default should be:
      #        assert_redirected_to workflow_ports_path(assigns(:workflow_port))
      #        but controller is redirecting back to edit so changed to:
      assert_redirected_to edit_workflow_profile_path(@workflow_port.workflow_id)
      # now need to assert that when saving, the previous annotation is saved in
      # the previous name, description and example fields are saved on the disp
      # fileds
      @saved_wfp = TavernaLite::WorkflowPort.find(@workflow_port.id)
      assert_equal(@workflow_port.old_name, @saved_wfp.old_name)
      assert_equal(@workflow_port.old_description, @saved_wfp.old_description)
      assert_equal(@workflow_port.old_example, @saved_wfp.old_example)
      assert_equal(@workflow_port.name, @saved_wfp.name)
      assert_equal(@workflow_port.description, @saved_wfp.description)
      assert_equal(@workflow_port.example, @saved_wfp.example)
    end

    test "should update workflow_port name description and example" do
      old_port = @workflow_port
      # Change description and save
      put :save_custom_inputs, {"workflow_id"=>@workflow_port.workflow_id,
        "selected_tab"=>"components", "selected_choice"=>"inputs",
        "file_uploads"=>{"name_for_name"=>"newname",
        "description_for_name"=>"New description",
        @workflow_port.name => "New example", "display_for_name"=>"1"},
        "commit"=>"Save", "id"=>@workflow_port.workflow_id}
      # verify that redirects correctly
      assert_redirected_to edit_workflow_profile_path(@workflow_port.workflow_id)
      # verify that the new values are aved and old ones are stored
      @saved_wfp = TavernaLite::WorkflowPort.find(@workflow_port.id)
      assert_equal(@workflow_port.name, @saved_wfp.old_name)
      assert_equal("newname", @saved_wfp.name)
      assert_equal(@workflow_port.description, @saved_wfp.old_description)
      assert_equal("New description", @saved_wfp.description)
      assert_equal(@workflow_port.example, @saved_wfp.old_example)
      assert_equal("New example", @saved_wfp.example)
    end
    # need to test resets
  end
end
