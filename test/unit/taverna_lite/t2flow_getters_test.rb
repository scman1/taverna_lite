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
# BioVeL Taverna Lite is a prototype interface provided to support web-based
# inspection and modification of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
require 'test_helper'

module TavernaLite
  class T2flowGettersTest < ActiveSupport::TestCase
    setup do
      # Set up the workflow file path so it can be used in different tests.
      # Using MatrixModelBootstrapNestedAndComponents.t2flow
      # this file mixes components and nested workflows
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename ='MatrixModelBootstrapNestedAndComponents.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_01 = to_there
    end
    test "01 should get all processor ports from workflow" do
      # modify the t2flow file by writing annotations
      wf_reader = T2flowGetters.new
      outputs01 = wf_reader.get_processors_outputs(@workflow_01)
      # the number of outputs should be the same
      puts "\n*****************************************************************"
      puts "PROCESSORS: " + outputs01.count.to_s
      out_count = 0
      puts outputs01
      outputs01.each { |port_k,port_v|
        outputs01[port_k]["ports"].each { |k,v|
          unless v[:connections].nil? then out_count += v[:connections].count end
        }
      }
      #need to check why the sum is not working
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      outputs02 = model.all_sinks
      # could try to assert that each node reported as used is actually used
      puts "FROM GETTERS: " + out_count.to_s
      puts "FROM T2FLOW:  " + outputs02.count.to_s
      outputs02.each do |sink|
        puts sink.name
      end
      puts "*****************************************************************\n"
      assert_equal(out_count,outputs02.count)
    end
    # Pending test of swap component
  end
end
