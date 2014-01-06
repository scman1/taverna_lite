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
      fixtures_path = ActiveSupport::TestCase.fixture_path
      # A workflow with other types of processors outputs
      # HelloBilingual.t2flow
      filename ='HelloBilingual.t2flow'
      from_here = fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/HelloBilingual2.t2flow'
      FileUtils.cp from_here, to_there
      @workflow_02 = to_there
      # Set up the workflow file paths that will be used in different tests.
      # MatrixModelBootstrapNestedAndComponents.t2flow
      # This file mixes components and nested workflows, it has:
      #  - 4 outputs,
      #  - 12 inner links (not counting links form workflow input ports)
      #  - 15 processor output ports (9 of them used)
      #  - 7 processors (2 nested workflow, 5 components)
      filename ='MatrixModelBootstrapNestedAndComponents.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_03 = to_there
      # MatrixModelBootstrapComponents.t2flow
      # This file contains only workflow components, it has:
      #  - 4 outputs,
      #  - 3 inputs,
      #  - 12 inner links (not counting links form workflow input ports)
      #  - 15 processor output ports (9 of them used)
      #  - 7 processors (all components)
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename ='MatrixModelBootstrapComponents.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_04 = to_there
      # Bootstrap_of_observations.t2flow
      # This file contains only rsheell processors, it has:
      #  - 5 outputs,
      #  - 6 inputs,
      #  - 10 inner links (not counting links form workflow input ports)
      #  - 9 processor output ports (7 of them used)
      #  - 5 processors (all rshell)
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename ='Bootstrap_of_observations.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_05 = to_there
    end

    test "00 get component outputs" do
      wf_reader = T2flowGetters.new
      component={}
      component["familyName"] = "POPMOD"
      component["registryBase"] = "http://www.myexperiment.org"
      component["componentVersion"]="1"
      component["componentName"]="BootstrapOfObservTrans"
      x = wf_reader.get_component_outputs(component)
      assert !x.nil?
      assert_equal(5, x.count)
      component={}
      component["familyName"] = "POPMOD"
      component["registryBase"] = "http://www.myexperiment.org"
      component["componentVersion"]="7"
      component["componentName"]="StageMatrixFromCensus"
      x = wf_reader.get_component_outputs(component)
      assert !x.nil?
      assert_equal(6, x.count)
    end

    test "01 get processor ports and connections from workflow" do
      # first get processor outputs
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_03)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_03)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_outs_count = t2_model.all_sinks.count
      t2f_links_count = t2_model.datalinks.count
      t2f_links = t2_model.datalinks
      connection_count = 0
      outs_count = 0
      proc_outs.each { |port_k,port_v|
        proc_outs[port_k][:ports].each { |k,v|
          outs_count += 1
          unless v[:connections].nil? then
            connection_count += v[:connections].count
            source = port_k + ":" + k
            connection_exists = false
            # assert that each connection reported is real
            v[:connections].each {|sink|
              t2f_links.each{|t2_link|
                if (t2_link.sink == sink && t2_link.source == source)
                  connection_exists = true
                  break
                end
              }
              assert connection_exists
            }
          end
        }
      }
      # @worklfow_01 has 12 inner connections
      assert_equal(12, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_01 has 15 ports
      assert_equal(15,outs_count)
      # expect less outputs than those reported reported by t2flow
      assert_operator(outs_count,:<=,t2f_outs_count)
    end

    test "02 get processor ports and connections from workflow components" do
      processor = "StageMatrixFromCensus"
      port = "report"
      # first get processor outputs
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_04)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_04)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_outs_count = t2_model.all_sinks.count
      t2f_links_count = t2_model.datalinks.count
      t2f_links = t2_model.datalinks
      # the number of outputs should be the same
      connection_count = 0
      outs_count = 0
      proc_outs.each { |port_k,port_v|
        port_k
        proc_outs[port_k][:ports].each { |k,v|
          outs_count += 1
          unless v[:connections].nil? then
            connection_count += v[:connections].count
            source = port_k + ":" + k
            connection_exists = false
            # assert that each connection reported is real
            v[:connections].each {|sink|
              t2f_links.each{|t2_link|
                if (t2_link.sink == sink && t2_link.source == source)
                  connection_exists = true
                  break
                end
              }
              assert connection_exists
            }
          end
        }
      }
      # @worklfow_02 has 12 inner connections
      assert_equal(connection_count,12)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_02 has 15 ports
      assert_equal(outs_count,15)
      # expect more outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end
    test "03 get processor ports and connections from workflow components" do
      processor = "StageMatrixFromCensus"
      port = "report"
      # first get processor outputs
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_02)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_02)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_outs_count = t2_model.all_sinks.count
      t2f_links_count = t2_model.datalinks.count
      t2f_links = t2_model.datalinks
      # the number of outputs should be the same
      connection_count = 0
      outs_count = 0
      proc_outs.each { |port_k,port_v|
        port_k
        proc_outs[port_k][:ports].each { |k,v|
          outs_count += 1
          unless v[:connections].nil? then
            connection_count += v[:connections].count
            source = port_k + ":" + k
            connection_exists = false
            # assert that each connection reported is real
            v[:connections].each {|sink|
              t2f_links.each{|t2_link|
                if (t2_link.sink == sink && t2_link.source == source)
                  connection_exists = true
                  break
                end
              }
              assert connection_exists
            }
          end
        }
      }
      # @worklfow_02 has 4 inner connections
      assert_equal(4, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_02 has 4 ports
      assert_equal(4, outs_count)
      # expect more outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end

    test "04 get processor ports and connections from rshell processors" do
      processor = "StageMatrixFromCensus"
      port = "report"
      # first get processor outputs
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_05)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_outs_count = t2_model.all_sinks.count
      t2f_links_count = t2_model.datalinks.count
      t2f_links = t2_model.datalinks
      # the number of outputs should be the same
      connection_count = 0
      outs_count = 0
      proc_outs.each { |port_k,port_v|
        port_k
        proc_outs[port_k][:ports].each { |k,v|
          outs_count += 1
          unless v[:connections].nil? then
            connection_count += v[:connections].count
            source = port_k + ":" + k
            connection_exists = false
            # assert that each connection reported is real
            v[:connections].each {|sink|
              t2f_links.each{|t2_link|
                if (t2_link.sink == sink && t2_link.source == source)
                  connection_exists = true
                  break
                end
              }
              assert connection_exists
            }
          end
        }
      }
      # @worklfow_02 has 4 inner connections
      assert_equal(10, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_02 has 9 ports
      assert_equal(9, outs_count)
      # expect more outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end

    test "06 get components list from workflow" do
      # first get workflow components
      wf_reader = T2flowGetters.new
      components_list = wf_reader.get_workflow_components(@workflow_04)
      # the workflow has 6 components
      assert_equal(6, components_list.count)
      # all components should be registered so no nil values
      components_list.each { |comp_k, comp_v|
        assert_not_nil(comp_k,"Key is nil")
        assert_not_nil(comp_v[0],"component is nil")
        assert_not_nil(comp_v[1],"workflow in component is nil")
      }
    end # test 06
    test "07 get ports list from workflow" do
      # first get workflow ports
      wf_reader = T2flowGetters.new
      ports_list = wf_reader.get_workflow_ports(@workflow_04)
      file_data = File.open(@workflow_04)
      t2_model = T2Flow::Parser.new.parse(file_data)

      t2f_outs = t2_model.sinks
      t2f_ins = t2_model.sources

      # assert that all returned ports are the same as those reported by model
      ports_list.each { |port_k, port_v|
        found = false
        if port_v.port_type_id==1
          t2f_ins.each {|port_in|
            if port_in.name == port_v.name
              found = true
              break
            end
          }
        elsif port_v.port_type_id==2
          t2f_outs.each {|port_out|
            if port_out.name == port_v.name
              found = true
              break
            end
          }
          assert(found)
        end
      }
      t2f_ins.each {|port_in|
         # assert that the port was recovered and asigned a correct type
        assert(ports_list.include?(port_in.name), port_in.name +
          " input port is missing")
        assert_equal(1, ports_list[port_in.name].port_type_id )
      }
      t2f_outs.each {|port_out|
         # assert that the port was recovered and asigned a correct type
        assert(ports_list.include?(port_out.name), port_out.name +
          " input port is missing")
        assert_equal(2, ports_list[port_out.name].port_type_id )
      }

      # the workflow has same number of inputs and outputs components
      assert_equal(t2f_outs.count+t2f_ins.count, ports_list.count)
    end # test 07
  end
end
