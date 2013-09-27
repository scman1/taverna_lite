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

module TavernaLite
  class WorkflowComponentsController < ApplicationController
    # GET /workflow_components
    # GET /workflow_components.json
    def index
      @workflow_components = WorkflowComponent.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @workflow_components }
      end
    end

    # GET /workflow_components/1
    # GET /workflow_components/1.json
    def show
      @workflow_component = WorkflowComponent.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @workflow_component }
      end
    end

    # GET /workflow_components/new
    # GET /workflow_components/new.json
    def new
      @workflow_component = WorkflowComponent.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @workflow_component }
      end
    end

    # GET /workflow_components/1/edit
    def edit
      @workflow_component = WorkflowComponent.find(params[:id])
    end

    # POST /workflow_components
    # POST /workflow_components.json
    def create
      @workflow_component = WorkflowComponent.new(params[:workflow_component])

      respond_to do |format|
        if @workflow_component.save
          format.html { redirect_to @workflow_component, notice: 'Workflow component was successfully created.' }
          format.json { render json: @workflow_component, status: :created, location: @workflow_component }
        else
          format.html { render action: "new" }
          format.json { render json: @workflow_component.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /workflow_components/1
    # PUT /workflow_components/1.json
    def update
      @workflow_component = WorkflowComponent.find(params[:id])

      respond_to do |format|
        if @workflow_component.update_attributes(params[:workflow_component])
          format.html { redirect_to @workflow_component, notice: 'Workflow component was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @workflow_component.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /workflow_components/1
    # DELETE /workflow_components/1.json
    def destroy
      @workflow_component = WorkflowComponent.find(params[:id])
      @workflow_component.destroy

      respond_to do |format|
        format.html { redirect_to workflow_components_url }
        format.json { head :no_content }
      end
    end

    # Replace the selected component on the workflow
    def replace
      @workflow = Workflow.find(params[:id])
      @from_op = 'replace'
      processor_name = params[:processor_name]
      replacement_id = WorkflowComponent.find(params[:component_id])
      # get the workflow file and parse it as an XML document
      xmlFile = @workflow.workflow_filename
      doc = XML::Parser.file(xmlFile, :options => XML::Parser::Options::NOBLANKS).parse
      #replace the component
      replace_workflow_components(doc,processor_name,replacement_id)
      #label the workflow as produced by taverna lite
      doc.root["producedBy"]="TavernaLite_v_0.3.8"
      # save workflow in the host app passing the file
      File.open(xmlFile, "w:UTF-8") do |f|
        f.write doc.root
      end
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'componet replaced'}
        format.json { head :no_content }
      end
    end

    # Get the components for a given workflow
    def replace_workflow_components(doc,processor_name,replacement_id)
      replacement_component = WorkflowComponent.find(replacement_id)
      a=get_node_containing(doc.root,'dataflow/processors/processor/name/', processor_name)
      b=get_node(a,"activities/activity/configBean")
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
    end
  end # Class WorkflowComponentsController
end # Module TavernaLite
