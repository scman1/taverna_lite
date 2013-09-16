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

require_dependency "taverna_lite/application_controller"
require "xml"

module TavernaLite
  class WorkflowProfilesController < ApplicationController
  #workflow store should be a setting on the host application
  WORKFLOW_STORE = Rails.root.join('public', 'workflow_store')
    def edit
      @workflow = TavernaLite.workflow_class.find(params[:id])
      @author = TavernaLite.author_class.find(@workflow.user_id)
      @workflow_profile = WorkflowProfile.new(author_id: @author.id, workflow_id: @workflow.id)
      # get inputs from the model and any customisation if they exist
      @sources, @source_descriptions = @workflow_profile.get_inputs
      @custom_inputs = @workflow_profile.get_custom_inputs
      # get outputs from the model and any customisation if they exist
      @sinks, @sink_descriptions = @workflow_profile.get_outputs
      @custom_outputs = @workflow_profile.get_custom_outputs
      #get errors and error codes
      @workflow_errors = @workflow_profile.get_errors
      @workflow_error_codes = @workflow_profile.get_error_codes
      #get the workflow processors to display structure
      @processors = @workflow_profile.get_processors
      @ordered_processors = @workflow_profile.get_processors_in_order
    end

    def update_profile
      @workflow = TavernaLite.workflow_class.find(params[:id])
      name =  params[:workflow][:name]
      title = params[:workflow][:title]
      author = params[:workflow][:author]
      description = params[:workflow][:description]
      @workflow.name = name
      @workflow.title = title
      @workflow.author = author
      @workflow.description = description
      # open the workflow file
      xmlFile = @workflow.workflow_filename
      document = XML::Parser.file(xmlFile, :options => XML::Parser::Options::NOBLANKS).parse
      # add annotations (title, author, description)
      insert_annotation(document, "author", author)
      insert_annotation(document, "description", description)
      insert_annotation(document, "title", title)
      # get the name node
      name_node = get_node_by_name(document.root,'name')
      # add name
      name_node.content = name
      document.root["producedBy"]="TavernaLite_v_0.3.8"
      # save workflow in the host app passing the file
      File.open(xmlFile, "w:UTF-8") do |f|
        f.write document.root
      end
      @workflow.save
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'Workflow annotations updated'}
        format.json { head :no_content }
       end
    end

    def copy
      # just copy the workflow, not the entire profile, need workflow and author
      @workflow = TavernaLite.workflow_class.find(params[:id])
      @author = TavernaLite.author_class.find(params[:user_id])
    end

    def save_as
      # get workflow again
      workflow = TavernaLite.workflow_class.find(params[:id])
      # clean the input to allow only valid characters for filenames
      title =   params[:workflow][:title].gsub(/[^\w\s\.\-]/, '')
      @author = TavernaLite.author_class.find(params[:workflow][:author_id])
      # create the new workflow using the workflow_class and the values
      @new_wf = TavernaLite.workflow_class.new(:name => workflow.name,
        :description=>workflow.description, :title => title,
        :author => workflow.author)
      @new_wf.user_id = @author.id
      @new_wf.save
      file_name = title.clone
      file_name = file_name.gsub! /\s/, '_'
      @new_wf.workflow_file = file_name+".t2flow"      # after save copy the workflow file
      @new_wf.save
      # create the WORKFLOW_STORE Folder if it does not exist
      FileUtils.mkdir_p(File.join(WORKFLOW_STORE, "#{@new_wf.id}"), :mode => 0700)
      FileUtils.cp(workflow.workflow_filename,@new_wf.workflow_filename)
      respond_to do |format|
        format.html { redirect_to main_app.workflow_path(@new_wf), :notice => 'Workflow Copied'}
        format.json { head :no_content }
       end
    end

    private
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

    def get_node_by_name(root,name)
      root.each_element do |dataflow|
        dataflow.each_element do |element|
          if element.name == name
            return element
          end
        end
      end
      return nil
    end

    def insert_annotation(xml_doc = nil, annotation_type = "author",
      annotation_text = "Unknown")
      annotations = get_node_by_name(xml_doc.root,'annotations')
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
end
