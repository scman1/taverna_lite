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
      @author = TavernaLite.author_class.find(@workflow.user_id) # This should be current user
      #find or create the profile
      @workflow_profile = WorkflowProfile.find_by_author_id_and_workflow_id(@author.id,@workflow.id)
      if @workflow_profile == nil
        @workflow_profile = WorkflowProfile.new(:author_id => @author.id, :workflow_id => @workflow.id)
        @workflow_profile.save
      end
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
      @wf_components = get_workflow_components(@workflow_profile.id)
      @component_alternatives = get_component_alternatives(@wf_components)
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
      name_node = get_node(document.root,'dataflow/name')
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

    # Get the components for a given workflow
    def get_workflow_components(id)
      workflow_profile = WorkflowProfile.find(id)
      processors = workflow_profile.get_processors
      xmlFile = workflow_profile.workflow.workflow_filename
      doc = XML::Parser.file(xmlFile, :options => XML::Parser::Options::NOBLANKS).parse
      components = {}
      processors.each do |proc|
        if proc.type == 'component'
          wfc = WorkflowComponent.new()
          a=get_node_containing(doc.root,'dataflow/processors/processor/name/', proc.name)
          b=get_node(a,"activities/activity/configBean")
          #extract component info from the file
          b.children[0].each do |cacb|
            case cacb.name
              when 'registryBase'
              # node name: registryBase content: http://www.myexperiment.org
                wfc.registry = cacb.content
              when 'familyName'
              # node name: familyName content: POPMOD
                wfc.family = cacb.content
              when 'componentName'
              # node name: componentName content: StageMatrixFromCensus
                wfc.name = cacb.content
              when 'componentVersion'
              # node name: componentVersion content: 3
                wfc.version = cacb.content
            end
          end
          wfc_db = WorkflowComponent.find_by_name(wfc.name)
          wf = nil
          unless wfc_db.nil?
            wf =  TavernaLite.workflow_class.find(wfc_db.workflow_id)
          end
          components[proc.name] = [wfc, wf]
        end
      end
      return components
    end

    # Get the registered alternative components from a given list of components
    def get_component_alternatives(wf_components)
      component_alternatives = {}
      wf_components.each do |component|
        unless component[1][1].nil? then
          proc_name = component[0]
          name = component[1][0].name # the name of the component
          wfc_db = TavernaLite::WorkflowComponent.find_by_name(name) # get component in db
          # find alternatives registered in DB
          alternatives = TavernaLite::AlternativeComponent.where(:component_id=>wfc_db.id)
          # get details of alternative components
          unless alternatives.nil? then
            component_alternatives[proc_name] = []
            alternatives.each do |alt_comp|
              a_wfc = TavernaLite::WorkflowComponent.find(alt_comp.alternative_id)
              wf =  TavernaLite.workflow_class.find(a_wfc.workflow_id)
              component_alternatives[proc_name]<<[a_wfc,wf]
            end
          end
        end
      end
      return component_alternatives
    end

  end #Class: WorkflowProfilesController
end # Module: TavernaLite
