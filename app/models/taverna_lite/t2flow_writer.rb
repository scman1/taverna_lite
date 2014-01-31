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
  class T2flowWriter
    TLVersion = "TavernaLite_v_"+TavernaLite::VERSION

    # recursively finds the first occurrence of path in the given node and
    # returns the corresponding node
    # Example: a = get_node(doc.root,'dataflow/processors/processor/name/')
    def get_node(node,path)
      name = path.split("/")[0]
      rest = path.split("/")
      rest.delete(name)
      rest = rest.join("/")
      node.each_element do |element|
          if element.name == name
            if rest == ""
              return element
            else
              return get_node(element,rest)
          end
        end
      end
    end

    # recursively finds the first occurrence of path in the given node which
    # matches the content and returns the corresponding node:
    # Example: a = get_node_containing(doc.root,'dataflow/processors/processor/name/','Output_Stage_Matrix')
    def get_node_containing(node,path,content)
      if path == "" then
        return nil
      end
      name = path.split("/")[0]
      rest = path.split("/")
      rest.delete(name)
      rest = rest.join("/")
      node.each_element do |element|
        if element.name == name
           if rest == "" && element.content == content
            return element.parent
          else
            node = get_node_containing(element,rest,content)
            if node == nil
              next
            else
              return node
            end
          end
        end
      end
    end

    # Refactored methods using xpath only (REXML)
    Top_dataflow = "dataflow[@role='top']"
    # Save workflow annotations
    def save_wf_annotations(workflow_file, author, description, title, name)
      # parse workflow file as an XML document
      document = get_xml_document(workflow_file)
      top_df = document.root.elements[Top_dataflow]
      # add annotations (title, author, description)
      insert_node_annotation(top_df, "author", author)
      insert_node_annotation(top_df, "description", description)
      insert_node_annotation(top_df, "title", title)
      # get the name node
      name_node = document.root.elements[Top_dataflow].elements["name"]
      # add name
      name_node.text = name
      document.root.attributes["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        f.write document.root
      end
    end # Save workflow annotations

    # create annotations using XPATH
    def create_annotation(type, content)
      annotation = Element.new("annotation_chain")
      annotation.attributes["encoding"]="xstream"
      annotationchainimpl = Element.new("net.sf.taverna.t2.annotation.AnnotationChainImpl")
      annotationchainimpl.attributes["xmlns"]=""
      annotationassertions = Element.new("annotationAssertions")
      annotationassertionimpl = Element.new("net.sf.taverna.t2.annotation.AnnotationAssertionImpl")
      annotationbean = Element.new("annotationBean")
      annotationbean.attributes["class"]=type
      text_node = Element.new("text")
      text_node.text = ERB::Util.html_escape(content)
      date = Element.new("date")
      date.text = Time.now.to_s
      creators = Element.new("creators")
      curationEventList = Element.new("curationEventList")
      annotationbean.add_element(text_node)
      annotationassertionimpl.add_element(annotationbean)
      annotationassertionimpl.add_element(date)
      annotationassertionimpl.add_element(creators)
      annotationassertionimpl.add_element(curationEventList)
      annotationassertions.add_element(annotationassertionimpl)
      annotationchainimpl.add_element(annotationassertions)
      annotation.add_element(annotationchainimpl)
      annotation
    end

    # save workflow port annotaions using XPATH
    def save_wf_port_annotations(workflow_file, port_name, new_name, description,
      example_val,port_type=1)
      # parse workflow file as an XML document
      document = get_xml_document(workflow_file)
      # find the port node
      path_to_port = 'inputPorts'
      unless port_type == 1
        path_to_port = 'outputPorts'
      end
      # get the collection of ports
      ports = document.root.elements[Top_dataflow].elements[path_to_port]
      # find the port to annotate
      port_node = nil
      ports.elements.each {|a_port|
        if a_port.elements["name"].text == port_name
          port_node = a_port
          break
        end
      }
      unless port_node.nil?
        # add annotations (description, example)
        insert_node_annotation(port_node, "description", description)
        insert_node_annotation(port_node, "example", example_val)
        # get the name node
        name_node = port_node.elements['name']
        # change the port name
        if port_node.elements['name'] != new_name
          port_node.elements['name'].text = new_name
          # need to change datalinks too
          change_datalinks_for_port(document, port_name, new_name, port_type)
        end
        document.root.attributes["producedBy"] = TLVersion
        # save workflow in the host app passing the file
        File.open(workflow_file, "w:UTF-8") do |f|
          f.write document.root
        end
      end
    end

    # inser a port annotation using XPATH
    def insert_node_annotation(node = nil, annotation_type = "decription",
      annotation_text = "Blank")
      annotations = node.elements['annotations']
      annotation_bean = "net.sf.taverna.t2.annotation.annotationbeans"
      case annotation_type
        when "author"
          annotation_bean += ".Author"
        when "description"
          annotation_bean += ".FreeTextDescription"
        when "title"
          annotation_bean += ".DescriptiveTitle"
        when "example"
          annotation_bean += ".ExampleValue"
        else
          annotation_bean += ".FreeTextDescription"
      end
      #check if there is already an annotation of this type in the workflow
      new_ann = nil
      annt_bean_path = "annotation_chain"+
                       "/net.sf.taverna.t2.annotation.AnnotationChainImpl"+
                       "/annotationAssertions"+
                       "/net.sf.taverna.t2.annotation.AnnotationAssertionImpl"+
                       "/annotationBean"
      XPath.match(annotations,"#{annt_bean_path}[@class='#{annotation_bean}']").map {|x|
        unless x.nil?
          new_ann = x
          # if the annotation exists just change content
          new_ann.elements['text'].text = ERB::Util.html_escape(annotation_text)
        end
      }
      if new_ann.nil?
        new_ann = create_annotation(annotation_bean, annotation_text)
        annotations.add_element(new_ann)
      end
    end # insert port annotation

    # replace all datalinks referencing an input port on a workflow using XPATH
    def change_datalinks_for_port(doc, port_name, new_name, port_type=1)
      # loop through all datalinks containing port_name as source
      # at least one data link should be found
      dl_port_path = 'source/port'
      if port_type == 2
        dl_port_path = 'sink/port'
      end
      datalinks = doc.root.elements[Top_dataflow].elements["datalinks"]
      datalinks.children.each do |x|
        if x.class == REXML::Element
          if x.elements[dl_port_path].text == port_name
            x.elements[dl_port_path].text = new_name
          end
        end
      end
    end #method: change_datalinks_for_port

    # change all datalinks referencing the processors input and/or output ports
    def change_datalinks_for_processor(doc, processor_name, new_name)
      # loop through all datalinks containing processor_name as sink or source
      # at least one data link should be found
      dl_source_path = 'source/processor'
      dl_sink_path = 'sink/processor'
      datalinks = doc.root.elements[Top_dataflow].elements["datalinks"]
      datalinks.children.each do |x|
        if x.class == REXML::Element
          if !x.elements[dl_source_path].nil? &&
            x.elements[dl_source_path].text == processor_name
            x.elements[dl_source_path].text = new_name
          end
          if !x.elements[dl_sink_path].nil? &&
            x.elements[dl_sink_path].text == processor_name
            x.elements[dl_sink_path].text = new_name
          end
        end
      end
    end # change_datalinks_for_processor

    # saves wf_processor annotations and renames processor
    def save_wf_processor_annotations(workflow_file, processor_name,
      new_name, description)
      # parse workflow file as an XML document
      document = get_xml_document(workflow_file)
      # find the port node in the top dataflow
      processors = document.root.elements[Top_dataflow].elements["processors"]
      path_to_procesor_name = 'name'
      processor_node = nil
      processors.children.each do |x|
        if x.class == REXML::Element
          if x.elements[path_to_procesor_name].text == processor_name
            processor_node = x
          end
        end
      end

      # add annotations (description, example)
      insert_node_annotation(processor_node, "description", description)
      # change the processor name
      if new_name != processor_name
        # get the name node
        name_node = processor_node.elements[path_to_procesor_name]
        name_node.text = new_name
        # need to change datalinks too
        change_datalinks_for_processor(document, processor_name, new_name)
      end
      document.root.attributes["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        f.write document.root
      end
    end# method: save_wf_processor_annotations

    # remove a workflow port uses XPATH
    def remove_wf_port(workflow_file, port_name,port_type=1)
      # parse workflow file as an XML document
      document = get_xml_document(workflow_file)
      # remove port
      remove_port(document, port_name,port_type)
      document.root.attributes["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        f.write document.root
      end
    end #method: remove_wf_port

    #get the parsed xml document
    def get_xml_document(workflow_file)
      xml_file = File.new(workflow_file)
      document = Document.new(xml_file)
    end

    def remove_port(document, port_name,port_type=1)
      # find the port node
      path_to_port = 'inputPorts'
      unless port_type == 1
        path_to_port = 'outputPorts'
      end
      # get the collection of ports
      ports = document.root.elements[Top_dataflow].elements[path_to_port]
      # find the port to remove
      port_node = nil
      ports.elements.each {|a_port|
        if a_port.elements["name"].text == port_name
          port_node = a_port
          break
        end
      }
      # remove the port node
      unless port_node.nil?
        port_node.parent.delete(port_node)
      end
      # remove the datalinks referencing the port
      remove_datalinks_for_port(document, port_name, port_type)
    end

    def remove_datalinks_for_port(doc, port_name, port_type)
      dl_port_path = 'source/port'
      if port_type == 2
        dl_port_path = 'sink/port'
      end
      # loop through all datalinks containing port_name and delete if found
      datalinks = doc.root.elements[Top_dataflow].elements["datalinks"]
      datalinks.children.each do |x|
        if x.class == REXML::Element
          if x.elements[dl_port_path].text == port_name
            datalinks.delete(x)
          end
        end
      end
    end # remove_datalinks_for_port

    # add a workflow port uses XPATH
    def add_wf_port(workflow_file, processor_name, processor_port, port_name="",
      port_description="", port_example="", port_type=2, depth=0,granular=0)
      # parse workflow file as an XML document
      document = get_xml_document(workflow_file)
      root = document.root
      if port_type == 1
        add_wf_input(document, processor_name, processor_port, port_name,
           port_description, port_example,depth,granular)
      else
        add_wf_output(document, processor_name, processor_port, port_name,
           port_description, port_example,depth,granular)
      end
      #   - how to calculate depth and granular depth if required
      #   - UI should validate input of names "FOR ALL WF ELEMENTS"
      document.root.attributes["producedBy"] = TLVersion

      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        document.write f
      end
      # pending:
      # - add annotations (description and example)
      save_wf_port_annotations(workflow_file, port_name, port_name,
        port_description, port_example,2)
    end


    def add_wf_input (document, processor_name, processor_port, port_name="",
      port_description="", port_example="",depth=1,gr_depth=1)
      root = document.root
      # 01 Add the port
      inputs = root.elements[Top_dataflow].elements["inputPorts"]
      portname = Element.new("name")
      portname.text = port_name
      new_port = Element.new("port")
      new_port.add_element(portname)
      new_port.add_element(Element.new("annotations"))
      new_depth = Element.new("depth")
      new_depth.text = depth
      new_port.add_element(new_depth)
      inputs.add_element(new_port)
    end

    def add_wf_output (document, processor_name, processor_port, port_name="",
      port_description="", port_example="", depth=1,gr_depth=1)
      root = document.root
      # 01 Add the port
      outputs = root.elements[Top_dataflow].elements["outputPorts"]
      portname = Element.new("name")
      portname.text = port_name
      new_port = Element.new("port")
      new_port.add_element(portname)
      new_port.add_element(Element.new("annotations"))
      outputs.add_element(new_port)

      # 02 Add a datalink for the port
      no_proc = ""
      add_datalink(document,no_proc,port_name,processor_name,processor_port)

      #03 add the output map to the processor
      #04 add port to processor (expose it)
      processors = root.elements[Top_dataflow].elements["processors"]
      processors.elements.each("processor/name") { |prn|
        if prn.text == processor_name then
          the_processor = prn.parent
          output_maps = the_processor.elements["activities/activity/outputMap"]
          #check if map exists, if not add else skip this
          unless map_exists(output_maps, processor_port)
            new_map = Element.new("map")
            new_map.attributes["from"] = processor_port
            new_map.attributes["to"] = processor_port
            output_maps.add_element(new_map)
          end
          output_ports = the_processor.elements["outputPorts"]
          # check if port exists, if not add else skip this
          unless port_exists(output_ports, processor_port)
            new_outport = Element.new("port")
            new_outname = Element.new("name")
            new_outname.text = processor_port
            new_depth = Element.new("depth")
            # depth for single values (includuing a file or an image is 0)
            new_depth.text = depth
            new_granular = Element.new("granularDepth")
            new_granular.text = gr_depth
            new_outport.add_element(new_outname)
            new_outport.add_element(new_depth)
            new_outport.add_element(new_granular)
            output_ports.add_element(new_outport)
         end
        end
      }
    end

    def add_datalink(document, to_processor_name, to_port_name,
      from_processor_name, from_port_name)
      # get the datalinks element
      root = document.root
      datalinks = root.elements[Top_dataflow].elements["datalinks"]
      sink_port = Element.new("port")
      sink_port.text = to_port_name

      new_sink = Element.new("sink")
      new_sink.add_element(sink_port)
      if to_processor_name==""
        new_sink.attributes["type"] = "dataflow"
      else
        new_sink.attributes["type"] = "processor"
        sink_processor = Element.new("processor")
        sink_processor.text = to_processor_name
        new_sink.add_element(sink_processor)
      end

      new_source = Element.new("source")
      source_port = Element.new("port")
      source_port.text = from_port_name
      new_source.add_element(source_port)

      if from_processor_name==""
        new_source.attributes["type"] = "dataflow"
      else
        new_source.attributes["type"] = "processor"
        source_processor = Element.new("processor")
        source_processor.text = from_processor_name
        new_source.add_element(source_processor)
      end

      new_datalink = Element.new("datalink")
      new_datalink.add_element(new_sink)
      new_datalink.add_element(new_source)

      datalinks.add_element(new_datalink)
    end

    def map_exists(maps, processor_port)
      exists = false
      XPath.match(maps,"map[@from='#{processor_port}' and @to='#{processor_port}']").map {|x|
          if !x.nil? && x == true
            exists = true
          end
      }
      exists
    end
    def port_exists(ports, processor_port)
      exists = false
      XPath.match(ports,"port/name='#{processor_port}'").map {|x|
        if !x.nil? && x == true
          exists = true
        end
      }
      exists
    end

    # replace a component
    def replace_component(workflow_file,processor_name,replacement_id)
      # parse workflow file as an XML document
      document = get_xml_document(workflow_file)
      #replace the component
      replace_workflow_components(document,processor_name,replacement_id)
      #label the workflow as produced by taverna lite
      document.root.attributes["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        f.write document.root
      end
    end

    # replace a component on a workflow
    def replace_workflow_components(doc,processor_name,replacement_id)
      replacement_component = WorkflowComponent.find(replacement_id)

      processors = doc.root.elements[Top_dataflow].elements["processors"]
      path_to_procesor_name = 'name'
      processor_node = nil
      processors.children.each do |x|
        if x.class == REXML::Element
          if x.elements[path_to_procesor_name].text == processor_name
            processor_node = x
          end
        end
      end

      cb_path = "activities/activity/configBean"
      cb_path += "/net.sf.taverna.t2.component.ComponentActivityConfigurationBean"
      config_bean = processor_node.elements[cb_path]
      #put component info in the child node
      config_bean.elements['registryBase'].text = replacement_component.registry
      config_bean.elements['familyName'].text = replacement_component.family
      config_bean.elements['componentName'].text = replacement_component.name
      config_bean.elements['componentVersion'].text = replacement_component.version.to_s
    end # method replace_workflow_component

    def remove_processor(workflow_file,processor_name)
      # parse the workflow file as an XML document
      document = get_xml_document(workflow_file)
      #remove the component
      remove_workflow_processor(document,processor_name)
      #label the workflow as produced by taverna lite
      document.root.attributes["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        f.write document.root
      end
    end

    # remove a processor from a workflow
    def remove_workflow_processor(doc,processor_name)
      processors = doc.root.elements[Top_dataflow].elements["processors"]
      path_to_procesor_name = 'name'
      processor_node = nil
      processors.children.each do |x|
        if x.class == REXML::Element
          if x.elements[path_to_procesor_name].text == processor_name
            processor_node = x
          end
        end
      end
      # remove the datalinks referencing the processor
      remove_datalinks_for_processor(doc, processor_name)
      # remove control links referencing the processor
      remove_control_link_for_processor(doc, processor_name)
      # remove the port node
      processor_node.parent.delete(processor_node)
    end # method remove_workflow_processor

    def remove_datalinks_for_processor(doc, processor_name)
      dl_source_path = 'datalink/source/processor'
      dl_sink_path = 'datalink/sink/processor'
      datalinks = doc.root.elements[Top_dataflow].elements["datalinks"]
      datalinks.elements.each(dl_source_path) { |x|
        if x.text == processor_name
          dl = x.parent.parent
          # check if the output is connected to a workflow output, if it is,
          # remove corresponding output
          if dl.elements['sink'].attributes["type"] == 'dataflow'
            port_name = dl.elements['sink/port'].text
            remove_port(doc, port_name,port_type=2)
          end
          # check if the output is connected to a processor, if it is, remove
          # corresponding processor
          if dl.elements['sink'].attributes["type"] == 'processor'
            proc_name = dl.elements['sink/processor'].text
            remove_workflow_processor(doc, proc_name)
          end
          datalinks.delete(dl)
        end
      }
      # if it has sink links, just remove them
      datalinks.elements.each(dl_sink_path) { |x|
        if x.text == processor_name
          datalinks.delete(x.parent.parent)
        end
      }
    end # remove_datalinks_for_processor

    def remove_control_link_for_processor(doc, processor_name)
      condition_path = 'condition'
      controllinks = doc.root.elements[Top_dataflow].elements["conditions"]
      controllinks.elements.each(condition_path) { |x|
        if x.attributes['control'] == processor_name
          controllinks.delete(x)
        elsif x.attributes['target'] == processor_name
          controllinks.delete(x)
        end
      }
    end # remove_control_links_for_processor

    # Add a processor containinf a component and link it if links are provided
    def add_component_processor(workflow_file, processor_name, component,
      description="", input_links=[], output_links=[])
      if description == ""
        description = TavernaLite.workflow_class.find(component.workflow_id).description
      end
      # parse the workflow file as an XML document
      document = get_xml_document(workflow_file)
      # add the component
      add_wf_processor(document, processor_name, component)
      # add links to inputs
      # connect the processor if input links are provided
      unless input_links.empty?
        link_processor_inputs(document,input_links)
      end
      # add links to outputs

      # label the workflow as produced by taverna lite
      document.root.attributes["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(workflow_file, "w:UTF-8") do |f|
        f.write document.root
      end
      # add annotation to processor, if empty use component description
      save_wf_processor_annotations(workflow_file, processor_name,
        processor_name, description)
    end

    def link_processor_inputs(document,input_links)
      input_links.each { |il|
        link_from = il[0].split(":")
        link_dest = il[1].split(":")
        link_from_depth=il[2].split(":")
        link_dest_depth=il[3].split(":")

        if link_from.length>1
          from_proc = link_from[0]
          from_port = link_from[1]
        else
          from_port=link_from[0]
          from_proc=""
        end
        if link_dest.length>1
          to_proc = link_dest[0]
          to_port = link_dest[1]
        else
          to_port=link_dest[0]
          to_proc=""
        end
        if link_from_depth.length>1
          port_from_depth=link_from_depth[0]
          port_from_granular=link_from_depth[1]
        else
          port_from_depth=link_from_depth[0]
          port_from_granular=""
        end
        if link_dest_depth.length>1
          port_dest_depth=link_dest_depth[0]
          port_dest_granular=link_dest_depth[1]
        else
          port_dest_depth=link_dest_depth[0]
          port_dest_granular=""
        end
        add_datalink(document, to_proc, to_port, from_proc, from_port)
        add_input_port_and_mapping(document, to_proc, to_port,port_dest_depth,
          port_dest_granular)
        add_output_port_and_mapping(document, from_proc, from_port,port_from_depth,
          port_from_granular)
      }
    end

    def add_input_port_and_mapping(document, to_proc, to_port, depth, granular="")
      # get the processor element
      root = document.root
      processors = root.elements[Top_dataflow].elements["processors"]
      processors.elements.each("processor/name") { |prn|
        if prn.text == to_proc then
          the_processor = prn.parent
          input_maps = the_processor.elements["activities/activity/inputMap"]
          #check if map exists, if not add else skip this
          unless map_exists(input_maps, to_port)
            new_map = Element.new("map")
            new_map.attributes["from"] = to_port
            new_map.attributes["to"] = to_port
            input_maps.add_element(new_map)
          end
          input_ports = the_processor.elements["inputPorts"]
          #check if port exists, if not add else skip this
          unless port_exists(input_ports, to_port)
            new_inport = Element.new("port")
            new_inname = Element.new("name")
            new_inname.text = to_port
            new_depth = Element.new("depth")
            new_depth.text = depth
            new_inport.add_element(new_inname)
            new_inport.add_element(new_depth)
            input_ports.add_element(new_inport)
          end
          strategy_path="iterationStrategyStack/iteration/strategy"
          strategy = the_processor.elements[strategy_path]
          if strategy.elements["cross/port"].nil?
            new_cross = Element.new("cross")
            new_inport = Element.new("port")
            new_inport.attributes["name"]=to_port
            new_inport.attributes["depth"]=depth
            new_cross.add_element(new_inport)
            strategy.add_element(new_cross)
          else
            cross_ports = strategy.elements["cross"]
            exists = false
            cross_ports.elements.each {|cpt|
              if cpt.attributes["name"] == to_port
                exists = true
              end
            }
            if !exists
              new_inport = Element.new("port")
              new_inport.attributes["name"]=to_port
              new_inport.attributes["depth"]=depth
              cross_ports.add_element(new_inport)
            end
          end
        end
      }
    end
    def add_output_port_and_mapping(document, to_proc, to_port, depth="0", granular="0")
      # get the processor element
      root = document.root
      processors = root.elements[Top_dataflow].elements["processors"]
      processors.elements.each("processor/name") { |prn|
        if prn.text == to_proc then
          the_processor = prn.parent
          output_maps = the_processor.elements["activities/activity/outputMap"]
          #check if map exists, if not add else skip this
          unless map_exists(output_maps, to_port)
            new_map = Element.new("map")
            new_map.attributes["from"] = to_port
            new_map.attributes["to"] = to_port
            output_maps.add_element(new_map)
          end
          output_ports = the_processor.elements["outputPorts"]
          #check if port exists, if not add else skip this
          unless port_exists(output_ports, to_port)
            new_outport = Element.new("port")
            new_outname = Element.new("name")
            new_outname.text = to_port
            new_depth = Element.new("depth")
            new_depth.text = depth
            new_granularDepth = Element.new("granularDepth")
            new_granularDepth.text = granular
            new_outport.add_element(new_outname)
            new_outport.add_element(new_depth)
            new_outport.add_element(new_granularDepth)
            output_ports.add_element(new_outport)
          end
        end
      }
    end
    # add a workflow port uses XPATH
    def add_wf_processor(document, name, component)
      #processor_port="", port_name="",
      #port_description="", port_example="", port_type=2)
      root = document.root

      processors = root.elements[Top_dataflow].elements["processors"]

      # Build the processor node
      new_processor = Element.new("processor")
      # Add the name for the processor, if empty use the same as component name
      proc_name = Element.new("name")
      if name.nil? || name == ""
        proc_name.text = component.name
      else
        proc_name.text = name
      end

      new_processor.add_element(proc_name)

      # Add element for procesor inputs
      processor_inputs = Element.new("inputPorts")
      # this can be null at the beginning since it is not connected
      new_processor.add_element(processor_inputs)

      # Add element for procesor outputs
      processor_outputs = Element.new("outputPorts")
      # this can be null at the beginning since it is not connected
      new_processor.add_element(processor_outputs)

      # Add element for procesor annotations
      processor_annotations = Element.new("annotations")
      # this can be null at the beginning since it is not annotated
      new_processor.add_element(processor_annotations)

      # Build element for procesor activities
      processor_activities = Element.new("activities")
      # build an activity node for the component
      activity_node=build_activity_for_component(component)
      # add the activity node to activities
      processor_activities.add_element(activity_node)
      # add activities to processor
      new_processor.add_element(processor_activities)

      # Build element for dispatch stack
      processor_dispatch_stack = build_dispatch_stack_for_component()
      # add dispatch stack to processor
      new_processor.add_element(processor_dispatch_stack)

      # Build element for iteration stack
      processor_iteration_stack = build_iteration_stack_for_component()
      # add iteration stack to processor
      new_processor.add_element(processor_iteration_stack)

      # add the processor to the workflow
      processors.add_element(new_processor)
    end

    # Constant to build activity node
    Component_Activity = "<activity>
     <raven>
       <group>net.sf.taverna.t2.component</group>
       <artifact>component-activity</artifact>
       <version>1.1.2</version>
     </raven>
     <class>net.sf.taverna.t2.component.ComponentActivity</class>
     <inputMap />
     <outputMap />
     <configBean encoding='xstream'>
       <net.sf.taverna.t2.component.ComponentActivityConfigurationBean xmlns=''>
         <registryBase/>
         <familyName/>
         <componentName/>
         <componentVersion/>
       </net.sf.taverna.t2.component.ComponentActivityConfigurationBean>
     </configBean>
     <annotations />
    </activity>"
    def build_activity_for_component(component)
      nw_activity = Document.new(Component_Activity)
      cb_path = "activity/configBean"
      cb_path += "/net.sf.taverna.t2.component.ComponentActivityConfigurationBean"
      config_bean = nw_activity.elements[cb_path]
      #put component info in the child node
      config_bean.elements['registryBase'].text = component.registry
      config_bean.elements['familyName'].text = component.family
      config_bean.elements['componentName'].text = component.name
      config_bean.elements['componentVersion'].text = component.version.to_s
      return nw_activity.root
    end

    # Constant to build dispatch stack node
    Component_Dispatch_Stack="<dispatchStack>
      <dispatchLayer>
        <raven>
          <group>net.sf.taverna.t2.core</group>
          <artifact>workflowmodel-impl</artifact>
          <version>1.4</version>
        </raven>
        <class>
          net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.Parallelize
        </class>
        <configBean encoding='xstream'>
          <net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.ParallelizeConfig xmlns=''>
            <maxJobs>1</maxJobs>
          </net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.ParallelizeConfig>
        </configBean>
      </dispatchLayer>
      <dispatchLayer>
        <raven>
          <group>net.sf.taverna.t2.core</group>
          <artifact>workflowmodel-impl</artifact>
          <version>1.4</version>
        </raven>
        <class>net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.ErrorBounce</class>
        <configBean encoding='xstream'><null xmlns='' /></configBean>
      </dispatchLayer>
      <dispatchLayer>
        <raven>
          <group>net.sf.taverna.t2.core</group>
          <artifact>workflowmodel-impl</artifact>
          <version>1.4</version>
        </raven>
        <class>net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.Failover</class>
        <configBean encoding='xstream'>
          <null xmlns='' />
        </configBean>
      </dispatchLayer>
      <dispatchLayer>
        <raven>
          <group>net.sf.taverna.t2.core</group>
          <artifact>workflowmodel-impl</artifact>
          <version>1.4</version>
        </raven>
        <class>net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.Retry</class>
        <configBean encoding='xstream'>
          <net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.RetryConfig xmlns=''>
            <backoffFactor>1.0</backoffFactor>
            <initialDelay>1000</initialDelay>
            <maxDelay>5000</maxDelay>
            <maxRetries>0</maxRetries>
          </net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.RetryConfig>
        </configBean>
      </dispatchLayer>
      <dispatchLayer>
        <raven>
          <group>net.sf.taverna.t2.core</group>
          <artifact>workflowmodel-impl</artifact>
          <version>1.4</version>
        </raven>
        <class>net.sf.taverna.t2.workflowmodel.processor.dispatch.layers.Invoke</class>
        <configBean encoding='xstream'>
          <null xmlns='' />
        </configBean>
      </dispatchLayer>
    </dispatchStack>"
    def build_dispatch_stack_for_component()
      nw_dispatch = Document.new(Component_Dispatch_Stack)
      return nw_dispatch.root
    end

    # Constant to build iteration strategy node
    Component_Iteration_Strategy = "<iterationStrategyStack>
        <iteration>
           <strategy />
        </iteration>
      </iterationStrategyStack>"
    def build_iteration_stack_for_component()
      nw_strategy = Document.new(Component_Iteration_Strategy)
      return nw_strategy.root
    end
  end # class
end # module
