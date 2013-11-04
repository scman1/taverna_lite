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
# BioVeL Taverna Lite  is a prototype interface to Taverna Server which is
# provided to support easy inspection and execution of workflows.
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
    # get a list of all the processor outputs in the workflow with and indicate
    # if they are used (conncted to some port)
    def get_all_outputs(xml_filename)
      file_data = File.open(xml_filename)
      model = T2Flow::Parser.new.parse(file_data)
      processors = model.processors
      sinks = model.all_sinks
      outputs = {}
      # this does not work beacaus t2flow gem only returns used ports
      # reading the workflow does not help either since only ports used are
      # included in main dataflow. Need to read each of the actual components,
      # get their ports and present them.
      # So need to mix with going to the repository and getting the workflow and
      # then getting the outputs list from each component.
      # for nested ones need to read the nested ones and get ports from them
      # rscripts and other do actually
      processors.each do |pr|
        name = pr.name
        pr.outputs.each do |out|
          port_name = name+':'+out
          outputs[port_name]={:used=>false,:connected_to=>nil}
        end
      end
      datalinks = model.datalinks
      datalinks.each do |dl|
        if outputs.has_key?(dl.source)
          outputs[dl.source][:used] = true
          outputs[dl.source][:connected_to] = dl.sink
        end
      end
      return outputs
    end # method get_all_outputs

    # Constants for Paths
    ActivityConfigBeanPath="processors/processor/activities/activity/configBean"
    # Configuration Bean constants for activities
    ComponentBean = "net.sf.taverna.t2.component.ComponentActivityConfigurationBean"
    DataflowBean ="dataflow"

    # get the outputs ports from a nested workflow based on its ID
    def get_df_out_ports_info(document, id)
      ports = []
      XPath.match(document, "/workflow/dataflow[@id='#{id}']").map {|x|
        x.elements.each('outputPorts/port'){ |opt|
          ports << opt.elements[1].text
        }
      }
      return ports
    end

    # get the outputs ports from a component based on its signature
    def get_component_output_ports_info(component)
      ports = []
    end

    def get_processor_outputs(xml_filename)
      xml_file = File.new(xml_filename)
      document = Document.new(xml_file)
      all_ports=[]
      document.elements.each("workflow/dataflow"){ |e|
        if e.attributes["role"] =="top" then
        # go trough each processor and get the set of outputs associated to it
        # if dataflow, use dataflow ref attribute to identify the corresponding
        # nested workflow
        # if component, use registry, Family, name and version to find the
        # its ports references to port
          e.elements.each(ActivityConfigBeanPath){ |cb|
            x={}
            case cb.elements[1].name
              when ComponentBean
                cb.elements[1].elements.each { |el|
                  x[el.name]=el.text
                }
                x["ports"] = get_component_output_ports_info(x)
              when DataflowBean
                x[DataflowBean] = cb.elements[1].attributes['ref']
                x["ports"] = get_df_out_ports_info(document, x[DataflowBean])
            end
            all_ports<<x
          }
          break
        end
      }
      return all_ports
    end
  end # class
end # module
