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
module TavernaLite
  class T2flowWriter
     TLVersion = "TavernaLite_v_0.3.9"
     def save_wf_annotations(xml_filename, author, description, title, name)
      document = XML::Parser.file(xml_filename, :options => XML::Parser::Options::NOBLANKS).parse
      # add annotations (title, author, description)
      insert_annotation(document, "author", author)
      insert_annotation(document, "description", description)
      insert_annotation(document, "title", title)
      # get the name node
      name_node = get_node(document.root,'dataflow/name')
      # add name
      name_node.content = name
      document.root["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(xml_filename, "w:UTF-8") do |f|
        f.write document.root
      end
    end

    def save_wf_port_annotations(xml_filename, port_name, new_name, description, example_val,port_type=1)
      document = XML::Parser.file(xml_filename, :options => XML::Parser::Options::NOBLANKS).parse
      # find the port node
      path_to_port = 'dataflow/inputPorts/port/name'
      unless port_type == 1
        path_to_port = 'dataflow/outputPorts/port/name'
      end
      port_node = get_node_containing(document.root,path_to_port, port_name)
      # add annotations (description, example)
      insert_port_annotation(port_node, "description", description)
      insert_port_annotation(port_node, "example", example_val)
      # get the name node
      name_node = get_node(port_node,'name')
      # change the port name
      if new_name != port_name
        name_node.content = new_name
        # need to change datalinks too
        if  port_type == 1
          change_datalinks_for_input(document, port_name, new_name)
        else
          change_datalinks_for_output(document, port_name, new_name)
        end
      end
      document.root["producedBy"] = TLVersion
      # save workflow in the host app passing the file
      File.open(xml_filename, "w:UTF-8") do |f|
        f.write document.root
      end
    end

    #add a list of namespaces to the node
    #the namespaces formal parameter is a hash
    #with "prefix" and "prefix_uri" as
    #key, value pairs
    #prefix for the default namespace is "default"
    def add_namespaces( node, namespaces )
      #pass nil as the prefix to create a default node
      default = namespaces.delete( "default" )
      node.namespaces.namespace = XML::Namespace.new( node, nil, default )
      namespaces.each do |prefix, prefix_uri|
        XML::Namespace.new( node, prefix, prefix_uri )
      end
    end

    #add a list of attributes to the node
    #the attributes formal parameter is a hash
    #with "name" and "value" as
    #key, value pairs
    def add_attributes( node, attributes )
      attributes.each do |name, value|
        XML::Attr.new( node, name, value )
      end
    end

    #create a node with name
    #and a hash of namespaces or attributes
    #passed to options
    def create_node( name, options )
      node = XML::Node.new( name )

      namespaces = options.delete( :namespaces )
      add_namespaces( node, namespaces ) if namespaces

      attributes = options.delete( :attributes )
      add_attributes( node, attributes ) if attributes
      node
    end

    def create_annotation (type, content)
      annotation = create_node("annotation_chain", :attributes=>{"encoding"=>"xstream"})
      annotationchainimpl = create_node("net.sf.taverna.t2.annotation.AnnotationChainImpl", :attributes=>{"xmlns"=>""})
      annotationassertions = create_node("annotationAssertions", :attributes=>{})
      annotationassertionimpl = create_node("net.sf.taverna.t2.annotation.AnnotationAssertionImpl", :attributes=>{})
      annotationbean = create_node("annotationBean", :attributes=>{"class"=>type})
      text = create_node("text", :attributes=>{})
      text.content = content
      date = create_node("date", :attributes=>{})
      date.content = Time.now.to_s
      creators = create_node("creators", :attributes=>{})
      curationEventList = create_node("curationEventList", :attributes=>{})
      annotationbean << text
      annotationassertionimpl << annotationbean
      annotationassertionimpl << date
      annotationassertionimpl << creators
      annotationassertionimpl << curationEventList
      annotationassertions << annotationassertionimpl
      annotationchainimpl << annotationassertions
      annotation << annotationchainimpl
      annotation
    end

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

    def insert_annotation(xml_doc = nil, annotation_type = "author",
      annotation_text = "Unknown")
      annotations = get_node(xml_doc.root,'dataflow/annotations')
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
      annotations.children.each do |ann|
        if annotation_bean == ann.children[0].children[0].children[0].children[0].attributes['class']
          new_ann = ann.children[0].children[0].children[0].children[0].children[0]
          new_ann.content = ERB::Util.html_escape(annotation_text.to_s)
          break
        end
      end
      if new_ann.nil?
        annotations << create_annotation(annotation_bean, ERB::Util.html_escape(annotation_text))
      end
    end
    def insert_port_annotation(node = nil, annotation_type = "decription",
      annotation_text = "Blank")
      annotations = get_node(node,'annotations')
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
      annotations.children.each do |ann|
        if annotation_bean == ann.children[0].children[0].children[0].children[0].attributes['class']
          new_ann = ann.children[0].children[0].children[0].children[0].children[0]
          new_ann.content = ERB::Util.html_escape(annotation_text.to_s)
          break
        end
      end
      if new_ann.nil?
        annotations << create_annotation(annotation_bean, ERB::Util.html_escape(annotation_text))
      end
    end
    # replace a component
    def replace_component(xmlFile,processor_name,replacement_id)
      # get the workflow file and parse it as an XML document
      doc = XML::Parser.file(xmlFile, :options => XML::Parser::Options::NOBLANKS).parse
      #replace the component
      replace_workflow_components(doc,processor_name,replacement_id)
      #label the workflow as produced by taverna lite
      doc.root["producedBy"]="TavernaLite_v_0.3.8"
      # save workflow in the host app passing the file
      File.open(xmlFile, "w:UTF-8") do |f|
        f.write doc.root
      end
    end

    # replace all datalinks referencing an input port on a workflow
    def change_datalinks_for_input(doc, port_name, new_name)
      writer = T2flowWriter.new
      # loop through all datalinks containing port_name as source
      begin
        # at least one data link should be found
        data_link=writer.get_node_containing(doc.root,'dataflow/datalinks/datalink/source/port', port_name)
        unless data_link.nil?
          data_link.children.each do |dl_part|
            dl_part.content = new_name
          end
        end
      end while !data_link.nil?
    end # change_datalinks_for_input

    # replace all datalinks referencing an output port on a workflow
    def change_datalinks_for_output(doc, port_name, new_name)
      writer = T2flowWriter.new
      # loop through all datalinks containing port_name as sink
      begin
        # at least one data link should be found
        data_link=writer.get_node_containing(doc.root,'dataflow/datalinks/datalink/sink/port', port_name)
        unless data_link.nil?
          data_link.children.each do |dl_part|
            dl_part.content = new_name
          end
        end
      end while !data_link.nil?
    end # change_datalinks_for_output
    # replace a component on a workflow
    def replace_workflow_components(doc,processor_name,replacement_id)
      replacement_component = WorkflowComponent.find(replacement_id)
      writer = T2flowWriter.new
      a=writer.get_node_containing(doc.root,'dataflow/processors/processor/name/', processor_name)
      b=writer.get_node(a,"activities/activity/configBean")
      #put component info in the child node
      b.children[0].each do |cacb|
        case cacb.name
          when 'registryBase'
          # node name: registryBase content
            cacb.content = replacement_component.registry
          when 'familyName'
          # node name: familyName content
            cacb.content = replacement_component.family
          when 'componentName'
          # node name: componentName content
            cacb.content = replacement_component.name
          when 'componentVersion'
          # node name: componentVersion content
            cacb.content = replacement_component.version.to_s
        end
      end
    end # method replace_workflow_components
  end # class
end # module
