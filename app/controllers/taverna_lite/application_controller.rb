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
# BioVeL Taverna Lite is a prototype interface to provided to support
# the inspection and modification of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
#module TavernaLite
#  class ApplicationController < ActionController::Base
#  end
#end
require 'xml'
class TavernaLite::ApplicationController < ApplicationController
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
          new_ann.content = annotation_text
          break
        end
      end
      if new_ann.nil?
        annotations << create_annotation(annotation_bean, annotation_text)
      end
    end

end

