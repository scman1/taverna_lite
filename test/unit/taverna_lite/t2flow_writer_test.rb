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
  class T2flowWriterTest < ActiveSupport::TestCase
    # test saving workflow annotations, need to pass a valid workflow file and
    # values for name, description, title and author
    # need to call t2flow to read and validate that saved workflow is t2flow
    setup do
      # need a set up with the value of the workflow file path
      # copy the file so that it can be used in different tests
      #start with HelloAnyone Workflow
      @fixture_path = ActiveSupport::TestCase.fixture_path
      from_here = @fixture_path+'/test_workflows/HelloAnyone.t2flow'
      to_there = @fixture_path+'/test_workflows/test_result/HelloAnyone.t2flow'
      FileUtils.cp from_here, to_there
      @workflow_file_path = to_there
    end
    test "should update_workflow_annotations" do
      author = "Jonny A. Notator"
      description = "Extension to helloworld.t2flow\n\t this workflow takes a workflow input 'name' which is combined with the string constant 'Hello', using the local worker 'Concatenate two strings'.\nThe output is the concatenated string 'greeting'"
      name =  "Hello_Anyone"
      title = "Hello Anyone (Hello World V2)"
      # modify the file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_annotations(@workflow_file_path , author, description, title, name)
      # verify that the file is t2flow
      file_data = File.open(@workflow_file_path)
      model = T2Flow::Parser.new.parse(file_data)
      assert !model.nil?
      # verify that the fileannotaions in the file are
      # the same as those passed as parameters
    end
  end
end
