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
    setup do
      # need a set up with the value of the workflow file path copy the file so
      # that it can be used in different tests
      # using  HelloAnyone Workflow for testing workflow annotation
      #  - 1 output
      #  - 2 inner links
      #  - 2 processor output ports
      #  - 2 processors (1 constant 1 concatenation service)
      fixtures_path = ActiveSupport::TestCase.fixture_path
      from_here = fixtures_path+'/test_workflows/HelloAnyone.t2flow'
      to_there = fixtures_path+'/test_workflows/test_result/HelloAnyone.t2flow'
      FileUtils.cp from_here, to_there
      @workflow_01 = to_there
      # need a set up with the value of the workflow file path copy the file so
      # that it can be used in different tests
      # using  HelloAnyone Workflow for testing workflow annotation
      #  - 1 output
      #  - 2 inner links
      #  - 2 processor output ports
      #  - 2 processors (1 constant 1 concatenation service)
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename = 'HelloAnyone_na.t2flow'
      from_here = fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_02 = to_there
      # now need a new workflow with two outputs so one can be removed.
      # created hello bilingual english & spanish
      #  - 2 outputs
      #  - 4 inner links (not counting links form workflow input ports)
      #  - 4 processor output ports
      #  - 4 processors (2 constants, 2 concatenation services)
      filename = 'HelloBilingual.t2flow'
      from_here = fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_03 = to_there
      # MatrixModelBootstrapNestedAndComponents.t2flow
      # This file mixes components and nested workflows, it has:
      #  - 4 outputs,
      #  - 12 inner links (not counting links form workflow input ports)
      #  - 15 processor output ports (9 of them used)
      #  - 7 processors (2 nested workflow, 5 components)
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename ='MatrixModelBootstrapNestedAndComponents.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_04 = to_there
      # MatrixModelBootstrapComponents.t2flow
      # This file contains only workflow components, it has:
      #  - 4 outputs,
      #  - 12 inner links (not counting links form workflow input ports)
      #  - 15 processor output ports (9 of them used)
      #  - 6 processors (all components)
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename ='MatrixModelBootstrapComponents.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_05 = to_there
      # MatrixEigenBootstrapComp.t2flow
      # This file contains only workflow components, it has:
      #  - 11 outputs
      #  - 26 data links
      #  - 23 processor output ports (18 of them used)
      #  - 9 processors (all components)
      #  - 3 control links
      fixtures_path = ActiveSupport::TestCase.fixture_path
      filename ='MatrixEigenBootstrapComp.t2flow'
      from_here =fixtures_path+'/test_workflows/'+filename
      to_there = fixtures_path+'/test_workflows/test_result/'+filename
      FileUtils.cp from_here, to_there
      @workflow_06 = to_there
      @wf_component = taverna_lite_workflow_components(:tl_workflowcomponent_03)
      @wfc_eigenanalysis = taverna_lite_workflow_components(:eigenanalysis)
    end # Test setup
    test "01 should update_workflow_annotations" do
      author = "Stian Soiland Reyes"
       description = "Extension to helloworld.t2flow\n\t The workflow takes a "+
        "input called 'name' which is combined with the string constant "+
        "'Hello'\n\t A local worker processor called 'Concatenate two strings'"+
        " is used.\n\t The output is the concatenated string 'greeting'"
      name =  "Hello_Anyone"
      title = "Hello Anyone"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_annotations(@workflow_01 , author, description,
        title, name)
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      m_name = model.name
      m_author = model.annotations.authors[0].to_s
      m_title = model.annotations.titles[0].to_s
      m_description = model.annotations.descriptions[0].to_s
      assert_equal(m_name,name)
      assert_equal(m_author, author)
      assert_equal(m_title, title)
      assert_equal(m_description,  ERB::Util.html_escape(description))
    end #test 01

    test "02 should add workflow annotations" do
      author = "Stian Soiland Reyes"
      description = "Extension to helloworld.t2flow\n\t The workflow takes a "+
        "input called 'name' which is combined with the string constant "+
        "'Hello'\n\t A local worker processor called 'Concatenate two strings'"+
        " is used.\n\t The output is the concatenated string 'greeting'"
      name =  "Hello_Anyone"
      title = "Hello Anyone"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_annotations(@workflow_02 , author, description,
      title, name)
      file_data = File.open(@workflow_02)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      m_name = model.name
      m_author = model.annotations.authors[0].to_s
      m_title = model.annotations.titles[0].to_s
      m_description = model.annotations.descriptions[0].to_s
      assert_equal(m_name,name)
      assert_equal(m_author, author)
      assert_equal(m_title, title)
      assert_equal(m_description,  ERB::Util.html_escape(description))
    end
    test "03 should_uptate_input_annotations" do
      port_name = "name"
      new_name = "name"
      description = "Name that will be concatenated with the 'Hello ' string"
      example_val= "Hello Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_01 , port_name, new_name,
        description, example_val,1)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      #get the input port name description and example values
      port_name = ""
      port_example = ""
      port_description = ""
      model.sources.each do |source|
        port_name = source.name
        port_example = source.example_values[0]
        port_description = source.descriptions[0]
      end
      assert_equal(port_example,example_val)
      assert_equal(port_description,ERB::Util.html_escape(description))
    end
    # Pending test changing the name to the port, not trivial needs some work
    # need to also replace all refernces to the port for instance in datalinks
    test "04 should_uptate_input_name" do
      port_name = "name"
      new_name = "greeting_name"
      description = "Name that will be concatenated with the 'Hello ' string"
      example_val= "Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_01 , port_name, new_name,
        description, example_val,1)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      #get the input port name and verify it was changed
      in_file_name = ""
      model.sources.each do |source|
        in_file_name = source.name
      end
      assert_equal(in_file_name,new_name)
      # get the datalinks and verify they have been updated
      found = ""
      model.datalinks.each do |dl|
        if dl.source == new_name
          found = dl.source
        end
      end
      assert_equal(found, new_name)
      # just to be safe, check that no datalinks referencing old name exist
      found = ""
      model.datalinks.each do |dl|
        if dl.source == port_name
          found = dl.source
        end
      end
      assert_equal(found, "")
    end
    test "05 should_uptate_output_annotations" do
      port_name = "greeting"
      new_name = "greeting"
      description = "The resulting greeting message 'Hello + Name'"
      example_val= "Hello Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_01 , port_name, new_name,
        description, example_val,2)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      #get the output port name description and example values
      port_name = ""
      port_example = ""
      port_description = ""
      model.sinks.each do |sink|
        port_name = sink.name
        port_example = sink.example_values[0]
        port_description = sink.descriptions[0]
      end
      assert_equal(port_example,example_val)
      assert_equal(port_description,ERB::Util.html_escape(description))
    end #test 05 should_uptate_output_annotations

    # Changing the name to the port is not trivial since it requires replacing
    #  all references to the port in datalinks
    test "06 should_uptate_output_name" do
      port_name = "greeting"
      new_name = "greeting_message"
      description = "The resulting greeting message 'Hello + Name'"
      example_val= "Hello Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_01 , port_name, new_name,
        description, example_val,2)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      # get the input port name and verify it was changed
      port_name = ""
      model.sinks.each do |sink|
        if (sink.name == new_name)
          port_name = sink.name
        end
      end
      assert_equal(port_name,new_name)
      # get the datalinks and verify they have been updated
      found = ""
      model.datalinks.each do |dl|
        if dl.sink == new_name
          found = dl.sink
        end
      end
      assert_equal(found, new_name)
    end #test 06 should_uptate_output_name

    test "07 should_update_processor_description" do
      processor_name = 'hello'
      new_name = 'hello'
      description = "Constant string to build the greeting sentence"
      writer = T2flowWriter.new
      writer.save_wf_processor_annotations(@workflow_01 , processor_name,
        new_name, description)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      #verify that the processor description is the same as the one set
      saved_desc = ""
      model.processors.each do |proc|
        if proc.name == processor_name
          saved_desc = proc.description
        end
      end
      assert_equal(description,saved_desc)
    end # test 07 should_update_processor_description

    test "08 should update processor name and datalink" do
      processor_name = 'hello'
      new_name = 'hello_constant'
      description = "Constant string to build the greeting sentence"
      writer = T2flowWriter.new
      writer.save_wf_processor_annotations(@workflow_01 , processor_name,
        new_name, description)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      #verify that the processor description is the same as the one set
      saved_desc = ""
      model.processors.each do |proc|
        if proc.name == processor_name
          saved_desc = proc.description
        end
      end
      proc_name = ""
      proc_desc = ""
      #first verify that the name exists and has the desired description
      model.processors.each do |proc|
        if proc.name == new_name
          proc_name = proc.name
          proc_desc = proc.description
        end
      end
      assert_equal(proc_name,new_name)
      assert_equal(description,proc_desc)
    end # test 08 should update processor name and datalink

    test "09 should update processor name and all datalinks" do
      processor_name = 'Concatenate_two_strings'
      new_name = 'Join_Strings'
      description = "Local service for joining two strings"
      writer = T2flowWriter.new
      writer.save_wf_processor_annotations(@workflow_01 , processor_name,
        new_name, description)
      # verify that the file is t2flow
      file_data = File.open(@workflow_01)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      #verify that the processor description is the same as the one set
      saved_desc = ""
      model.processors.each do |proc|
        if proc.name == processor_name
          saved_desc = proc.description
        end
      end
      proc_name = ""
      proc_desc = ""
      #first verify that the name exists and has the desired description
      model.processors.each do |proc|
        if proc.name == new_name
          proc_name = proc.name
          proc_desc = proc.description
        end
      end
      assert_equal(proc_name,new_name)
      assert_equal(description,proc_desc)
    end # test 09 should update processor name and all datalinks

    test "10 should rename when there is more than one output" do
      # derived from test 03 edit name
      port_name = "saludo"
      new_name = "spanish_greeting"
      description = "The resulting greeting message in spanish 'Hola + Name'"
      example_val= "Hola Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_03 , port_name, new_name, description, example_val,2)
      # verify that the file is t2flow
      file_data = File.open(@workflow_03)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      # get the input port name and verify it was changed
      port_name = ""
      model.sinks.each do |sink|
        if (sink.name == new_name)
          port_name = sink.name
        end
      end
      assert_equal(port_name,new_name)
      # get the datalinks and verify they have been updated
      found = ""
      model.datalinks.each do |dl|
        if dl.sink == new_name
          found = dl.sink
        end
      end
      assert_equal(found, new_name)
    end # test 10 should rename when there is more than one output

    test "11 should delete output and datalinks" do
      # derived from test 03 edit name
      port_name = "saludo"
      new_name = "saludo"
      description = "The resulting greeting message in spanish 'Hola + Name'"
      example_val= "Hola Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.remove_wf_port(@workflow_03, port_name, 2)
      # verify that the file is t2flow
      file_data = File.open(@workflow_03)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      # get the input port name and verify it was removed
      found_name = ""
      model.sinks.each do |sink|
        if (sink.name == port_name)
          found_name = sink.name
        end
      end
      assert_equal(found_name,"")
      # get the datalinks and verify they have been updated
      found_link = ""
      model.datalinks.each do |dl|
        if dl.sink == port_name
          found_link = dl.sink
        end
      end
      assert_equal(found_link, "")
    end # test 11

#    test "12 add an output_port for StageMatrixFromCensus:report nested WF" do
#      processor = "StageMatrixFromCensus"
#      port = "report"
#      port_name="SMFC_report"
#      description=""
#      example=""
#      port_type=2
#
#      writer = T2flowWriter.new
#      writer.add_wf_port(@workflow_04 , processor, port,  port_name,
#        description, example, port_type)
#      # first get processor outputs
#      wf_reader = T2flowGetters.new
#      proc_outs = wf_reader.get_processors_outputs(@workflow_04)
#      # get t2flow model to check things returned from t2flow_getter
#      file_data = File.open(@workflow_04)
#      t2_model = T2Flow::Parser.new.parse(file_data)
#      t2f_all_outs_count = t2_model.all_sinks.count
#      t2f_outs_count = t2_model.sinks.count
#      t2f_links_count = t2_model.datalinks.count
#      t2f_links = t2_model.datalinks

#      # the number of outputs should be the same
#      connection_count = 0
#      outs_count = 0
#      proc_outs.each { |port_k,port_v|
#        port_k
#        proc_outs[port_k][:ports].each { |k,v|
#          outs_count += 1
#          unless v[:connections].nil? then
#            connection_count += v[:connections].count
#            source = port_k + ":" + k
#            connection_exists = false
#            # assert that each connection reported is real
#            v[:connections].each {|sink|
#              t2f_links.each{|t2_link|
#                if (t2_link.sink == sink && t2_link.source == source)
#                  connection_exists = true
#                  break
#                end
#              }
#              assert connection_exists
#            }
#          end
#        }
#      }
#      # t2flow should have a new output
#      assert_equal(5, t2f_outs_count)
#      # @worklfow_01 had 12 inner connections + 1 added now it has 13
#      assert_equal(13, connection_count)
#      # expect less links than those reported by t2flow
#      assert_operator(connection_count,:<=,t2f_links_count)
#      # @worklfow_01 has 15 ports this number should not change
#      assert_equal(15,outs_count)
#      # expect less outputs than those reported reported by t2flow
#      assert_operator(outs_count,:<=,t2f_all_outs_count)
#    end #test 12

    test "13 add an output_port for StageMatrixFromCensus:report component" do
      processor = "StageMatrixFromCensus"
      port = "report"
      port_name="SMFC_report"
      description=""
      example=""
      port_type=2

      # Before changes
      file_data = File.open(@workflow_05)

      t2_model = T2Flow::Parser.new.parse(file_data)

      writer = T2flowWriter.new
      writer.add_wf_port(@workflow_05 , processor, port,  port_name,
        description, example, port_type)
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_05)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_all_outs_count = t2_model.all_sinks.count
      t2f_outs_count = t2_model.sinks.count
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
      # t2flow should have a new output
      assert_equal(5, t2f_outs_count)
      # @worklfow_01 had 12 inner connections + 1 added now it has 13
      assert_equal(13, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_01 has 15 ports this number should not change
      assert_equal(15,outs_count)
      # expect less outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end #test 13 add an output_port for StageMatrixFromCensus:report component

    test "14 add an output_port for FirstProcessor:FirstPort any processor" do
      proc_name = ""
      proc_port = ""
      port_name=""
      description=""
      example=""
      port_type=2
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_03)
      proc_outs.each { |port_k,port_v|
        proc_name = port_k
        proc_outs[port_k][:ports].each { |k,v|
          proc_port = k
          break
        }
        break
      }
      port_name= proc_name + "_" + proc_port
      writer = T2flowWriter.new
      writer.add_wf_port(@workflow_03 , proc_name, proc_port,  port_name,
        description, example, port_type)
      # first get processor outputs
      proc_outs = wf_reader.get_processors_outputs(@workflow_03)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_03)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_all_outs_count = t2_model.all_sinks.count
      t2f_outs_count = t2_model.sinks.count
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
      # t2flow should have a new output
      assert_equal(3, t2f_outs_count)
      # @worklfow_01 had 4 inner connections + 1 added now it has 5
      assert_equal(5, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_01 has 15 ports this number should not change
      assert_equal(4, outs_count)
      # expect less outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end #test 14 add an output_port for FirstProcessor:FirstPort any processor

    test "15 add an output_port for FirstProcessor:FirstPort any component" do
      proc_name = ""
      proc_port = ""
      port_name=""
      description=""
      example=""
      port_type=2
      wf_reader = T2flowGetters.new
      proc_outs = wf_reader.get_processors_outputs(@workflow_05)
      proc_outs.each { |port_k,port_v|
        proc_name = port_k
        proc_outs[port_k][:ports].each { |k,v|
          proc_port = k
          break
        }
        break
      }
      port_name= proc_name + "_" + proc_port
      writer = T2flowWriter.new
      writer.add_wf_port(@workflow_05, proc_name, proc_port,  port_name,
        description, example, port_type)
      # first get processor outputs
      proc_outs = wf_reader.get_processors_outputs(@workflow_05)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_all_outs_count = t2_model.all_sinks.count
      t2f_outs_count = t2_model.sinks.count
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
      # t2flow should have a new output
      assert_equal(5, t2f_outs_count)
      # @worklfow_01 had 12 inner connections + 1 added now it has 5
      assert_equal(13, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_01 has 15 ports this number should not change
      assert_equal(15, outs_count)
      # expect less outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end #test 15 add an output_port for FirstProcessor:FirstPort any component

    test "16 add an output_port for FirstProcessor:FirstPort any component" do
      proc_name = "StageMatrixFromCensus"
      proc_port = "report"
      port_name="Matrix_Gen_Report"
      description="plain text report of the tables used for generating matrix"
      example=""
      port_type=2
      wf_reader = T2flowGetters.new
      writer = T2flowWriter.new
      writer.add_wf_port(@workflow_05, proc_name, proc_port,  port_name,
        description, example, port_type)
      # first get processor outputs
      proc_outs = wf_reader.get_processors_outputs(@workflow_05)
      # get t2flow model to check things returned from t2flow_getter
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      t2f_all_outs_count = t2_model.all_sinks.count
      t2f_outs_count = t2_model.sinks.count
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
      # t2flow should have a new output
      assert_equal(5, t2f_outs_count)
      # @worklfow_01 had 12 inner connections + 1 added now it has 5
      assert_equal(13, connection_count)
      # expect less links than those reported by t2flow
      assert_operator(connection_count,:<=,t2f_links_count)
      # @worklfow_01 has 15 ports this number should not change
      assert_equal(15, outs_count)
      # expect less outputs than those reported reported by t2flow
      # t2flow gem cannot read all the outputs in a component
      assert_operator(outs_count,:>=,t2f_outs_count)
    end #test 16 add an output_port for FirstProcessor:FirstPort any component


    # Test of swap component
    test "17 Swap component " do
      writer = T2flowWriter.new
      processor_name="Read_Census_Data_From_CSV_File"
      replacement_id= @wf_component.id

      writer.replace_component(@workflow_05,processor_name,replacement_id)
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(t2_model, nil)
    end #test 17xp

    # Test of delete component simple
    test "18 Delete a component with one output and no downstream link " do
      writer = T2flowWriter.new
      processor_name="EigenAnalysisToCSV"
      writer.remove_processor(@workflow_06,processor_name)
      file_data = File.open(@workflow_06)
      t2_model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(t2_model, nil)
      # After delete the workflow should change:
      #  - from 11 to 10 outputs (1 deleted)
      assert_equal(10, t2_model.sinks.count)
      #  - from 26 to 24 data links (2 deleted)
      assert_equal(24, t2_model.datalinks.count)
      #  - from 9 to 8 processors (1 deleted)
      assert_equal(8, t2_model.processors.count)
    end #test 18

    # Test of delete component complex
    test "19 Delete a component with two downstream processors" do
      writer = T2flowWriter.new
      processor_name="EigenAnalysis"
      writer.remove_processor(@workflow_06,processor_name)
      file_data = File.open(@workflow_06)
      t2_model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(t2_model, nil)
      # After delete the workflow should change:
      #  - from 11 to 4 outputs (7 deleted)
      assert_equal(4, t2_model.sinks.count)
      #  - from 26 to 15 data links (9 deleted)
      assert_equal(15, t2_model.datalinks.count)
      #  - from 9 to 6 processors (3 deleted)
      assert_equal(6, t2_model.processors.count)
      #  - from 3 to 1 control links (2 deleted)
      assert_equal(1, t2_model.coordinations.count)
    end #test 19

    # Test of add component without connecting it and with no description
    test "20 Add a component" do
      writer = T2flowWriter.new
      processor_name="EigenAnalysis"
      writer.add_component_processor(@workflow_05, processor_name,
        @wfc_eigenanalysis, "")
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(t2_model, nil)
      # After add the workflow should change:
      #  - from 6 to 7 processors (1 added)
      assert_equal(7, t2_model.processors.count)
    end #test 20
    # Test of add component connecting its inputs
    test "21 Add a component and connect inputs" do
      writer = T2flowWriter.new
      processor_name="EigenAnalysis_1"
      # input links are provided as a set of nested arrays.
      # each array contains source, sink, and depth
      # where source|sink = [processor:]port
      input_links = [
        ["StageMatrixFromCensus:stage_matrix","EigenAnalysis_1:stage_matrix","1"],
        ["Label","EigenAnalysis_1:speciesName","0"]]
      writer.add_component_processor(@workflow_05, processor_name,
        @wfc_eigenanalysis, "",  input_links)
      file_data = File.open(@workflow_05)
      t2_model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(t2_model, nil)
      # After add the workflow should change:
      #  - from 6 to 7 processors (1 added)
      assert_equal(7, t2_model.processors.count)
      #  - from 15 to 17 data links (9 deleted)
      assert_equal(17, t2_model.datalinks.count)
    end #test 21

    test "22 add an input_port not connected to any processor" do
      port_name="new port"
      description=""
      example=""
      port_type=1
      file_data = File.open(@workflow_03)
      t2_model = T2Flow::Parser.new.parse(file_data)
      proc_ins_before = t2_model.sources.count
      writer = T2flowWriter.new
      writer.add_wf_port(@workflow_03 , "", "",  port_name,
        description, example, port_type)
      file_data = File.open(@workflow_03)
      t2_model = T2Flow::Parser.new.parse(file_data)
      proc_ins_after = t2_model.sources.count
      assert_operator(proc_ins_after,:>,proc_ins_before)
    end #test 14 add an output_port for FirstProcessor:FirstPort any processor

  end
end
