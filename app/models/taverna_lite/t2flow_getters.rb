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
# inspection and modification of workflows
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.

# A class to handle writing changes to workflow file
require 'rexml/document'
include REXML
module TavernaLite
  class T2flowGetters
     TLVersion = "TavernaLite_v_"+TavernaLite::VERSION

    # Constants for Paths
    DataFlowPath = "workflow/dataflow"
    ActivityConfigBeanPath="processors/processor/activities/activity/configBean"

    # Configuration Bean constants for activities
    ComponentBean = "net.sf.taverna.t2.component.ComponentActivityConfigurationBean"
    DataflowBean ="dataflow"

    # get a list of all the processor outputs in the workflow and indicate
    # if they are used (conncted to some port)
    def get_processors_outputs(xml_filename)
      xml_file = File.new(xml_filename)
      document = Document.new(xml_file)
      all_processor_outputs={}
      document.elements.each(DataFlowPath){ |e|
        if e.attributes["role"] =="top" then
        # go trough each processor and get the set of outputs associated to it
        # if dataflow, use dataflow ref attribute to identify the corresponding
        # nested workflow
        # if component, use registry, Family, name and version to find the
        # its ports references to port
          e.elements.each(ActivityConfigBeanPath){ |cb|
            processor_name = ""
            x = {}
            # look at the parents for the processor name
            pr_node = cb.parent.parent.parent
            pr_node.elements.each("name"){ |prn|
              processor_name =  prn.text
            }
            case cb.elements[1].name
              when ComponentBean
                cb.elements[1].elements.each { |el|
                  x[el.name]=el.text
                }
                x["ports"] = get_component_outputs(x)
              when DataflowBean
                x[DataflowBean] = cb.elements[1].attributes['ref']
                x["ports"] = get_dataflow_outputs(xml_file, x[DataflowBean])
            end
            all_processor_outputs[processor_name] = x
          }
          break
        end
      }
      all_processor_outputs = get_ports_links(all_processor_outputs, xml_file)
      return all_processor_outputs
    end # method get_processor_outputs

    # get the outputs ports from a nested workflow using nested workflow ID
    def get_dataflow_outputs(xml_file, id)
      ports = {}
      dataflows = T2Flow::Parser.new.parse(xml_file).dataflows
      dataflows.each{ |df|
        if df.dataflow_id == id then
            df.sinks.each { |a_sink|
              description = ""
              unless a_sink.descriptions.nil?
                description = a_sink.descriptions.join.to_s
              end
              example = ""
              unless a_sink.example_values.nil?
                example = a_sink.example_values.join.to_s
              end
              ports[a_sink.name] = {:description=>description,
                :example=>example, :workflow_port => nil}
            }
          break
        end
      }
      ports
    end

    # get the outputs ports from a component based on its signature
    def get_component_outputs(component)
      ports = {}
      #should read from the repository but for the moment get it from local copy
      component = TavernaLite::WorkflowComponent.find(:all,
                     :conditions=>{
                       :family=>component["familyName"],
                       :registry=>component["registryBase"],
                       :version=>component["componentVersion"],
                       :name=>component["componentName"]})

      unless component.empty? then
        component = component[0]
        wfp=TavernaLite::WorkflowProfile.new(:workflow_id=>component.workflow_id)
        component_ports = wfp.get_custom_outputs
        component_ports.each { |cpt|
          ports[cpt.name] = {:description=>cpt.description,
            :example=> cpt.example, :workflow_port=>cpt}
        }
      end
      ports
    end # method get_component_output_ports_info

    # get information about a ports connections within the workflow
    def get_ports_links(all_processor_outputs, xml_file)
      datalinks = T2Flow::Parser.new.parse(xml_file).datalinks
      all_processor_outputs.each { |processor_key, a_processor|
        processor_name = processor_key
        a_processor["ports"].each { |port_key, a_port|
          port_name = port_key
          link_source = processor_name + ":" + port_name
          a_port[:connections] = []
          datalinks.each { |dl|
            if dl.source == link_source
              a_port[:connections] << dl.sink
            end
          }
        }
      }
    end # method get_port_links
  end # class
end # module
