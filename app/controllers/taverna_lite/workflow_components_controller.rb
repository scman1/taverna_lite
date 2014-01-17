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
        format.json { render :json => @workflow_components }
      end
    end

    # GET /workflow_components/1
    # GET /workflow_components/1.json
    def show
      @workflow_component = WorkflowComponent.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @workflow_component }
      end
    end

    # GET /workflow_components/new
    # GET /workflow_components/new.json
    def new
      @workflow_component = WorkflowComponent.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @workflow_component }
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
          format.html { redirect_to @workflow_component, :notice => 'Workflow component was successfully created.' }
          format.json { render :json => @workflow_component, :status =>  :created, :location => @workflow_component }
        else
          format.html { render :action => "new" }
          format.json { render :json => @workflow_component.errors, :status =>  :unprocessable_entity }
        end
      end
    end

    # PUT /workflow_components/1
    # PUT /workflow_components/1.json
    def update
      @workflow_component = WorkflowComponent.find(params[:id])

      respond_to do |format|
        if @workflow_component.update_attributes(params[:workflow_component])
          format.html { redirect_to @workflow_component, :notice => 'Workflow component was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @workflow_component.errors, :status =>  :unprocessable_entity }
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
      writer = T2flowWriter.new
      writer.replace_component(@workflow.workflow_filename,processor_name,replacement_id)
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'componet replaced'}
        format.json { head :no_content }
      end
    end

    # Remove the selected component from the workflow
    def remove
      @workflow = Workflow.find(params[:id])
      @from_op = 'remove'
      processor_name = params[:processor_name]
      writer = T2flowWriter.new
      writer.remove_workflow_processor(@workflow.workflow_filename,processor_name)
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'componet removed'}
        format.json { head :no_content }
      end
    end #method: replace
  end # Class WorkflowComponentsController
end # Module TavernaLite
