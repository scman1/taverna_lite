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
      prev_component_name = params[:prev_component_name]
      replacement_id = params["replace_#{prev_component_name}"][:component_id]
      replacement_comp = WorkflowComponent.find(replacement_id)
      logger.info "REPLACE THIS -----------------------------------------------"
      logger.info params
      logger.info @form_op
      logger.info "FROM "+ processor_name
      logger.info "TO " + replacement_comp.name
      logger.info "REPLACE ENDS -----------------------------------------------"
      writer = T2flowWriter.new
      writer.replace_component(@workflow.workflow_filename,processor_name,replacement_comp)
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'componet replaced'}
        format.json { head :no_content }
      end
    end  #method: replace

    # Remove the selected component from the workflow
    def remove
      @workflow = Workflow.find(params[:id])
      from_op = 'remove'
      processor_name = params[:processor_name]
      writer = T2flowWriter.new
      writer.remove_processor(@workflow.workflow_filename,processor_name)
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'componet removed'}
        format.json { head :no_content }
      end
    end #method: remove

    # Add new component to workflow
    def add
      @workflow = Workflow.find(params[:id])
      @from_op = params[:action]
      processor_name = params[:processor_name]

      form_id = "add_to_" + processor_name
      new_comp = TavernaLite::WorkflowComponent.find(params[form_id]["component_id"])
      name_field = "name_for_comp_"+new_comp.name
      new_processor_name = params[form_id][name_field]
      description = params[form_id]["description"]
      # need to get links
      #  input_links = [
      #    ["StageMatrixFromCensus:stage_matrix","EigenAnalysis:stage_matrix","1"],
      #    ["Label","EigenAnalysis:speciesName","0"]]
      # NEED TO CHANGE THIS TO PASS CORRECT DEPTHS TO PORTS...!!!!!
      input_links = []
      new_wf_inputs = []
      params[form_id].each { |k,v|
        if k.start_with?("connects_")
          dest_in_name = k.sub("connects_","")
          new_dest = new_processor_name + ':' + dest_in_name
          dest_depth = get_comp_in_port_depth(new_comp,dest_in_name)
          pro_from = processor_name+":"+v
          if v == "New_Workflow_Input"
            new_wf_in =  new_processor_name +"_"+k.sub("connects_","")
            # the depth of a new workflo input is the same as the depth of the
            # processor input port it is connected to
            input_links << [new_wf_in,new_dest,dest_depth,dest_depth]
            new_wf_inputs << [new_wf_in]
          else
            wf_file = @workflow.workflow_filename
            from_depth = get_proc_out_port_depths(wf_filen,processor_name,v)
            input_links << [pro_from,new_dest,from_depth,dest_depth]
          end
        end
      }
      writer = T2flowWriter.new
      # first, if there are new input ports to create, add them to WF
      new_wf_inputs.each {|wfins|
        writer.add_wf_port(@workflow.workflow_filename, "", "",  wfins[0],
          "", "", 1)
      }

      # add an link the component
      writer.add_component_processor(@workflow.workflow_filename,
       new_processor_name, new_comp, description, input_links)

      logger.info "ADD THIS--------------------------------------------------"
      logger.info params
      logger.info @form_op
      logger.info "FROM "+ processor_name
      logger.info "TO " + new_comp.name
      logger.info "NEW PROCESSOR NAME " + new_processor_name
      logger.info "DESCRIPTION\n" + description
      logger.info "Links: " + input_links.to_s
      logger.info "links to new inputs: " + new_wf_inputs.to_s
      logger.info "ADD ENDS--------------------------------------------------"
      respond_to do |format|
        format.html {
          redirect_to(taverna_lite.edit_workflow_profile_path(@workflow),
            :notice => 'componet added')
        }
        format.json { head :no_content }
      end
    end #method: add

    def get_proc_out_port_depths(wf_filename,proc_name,out_name)
      # get the processor component
      reader = TavernaLite::T2flowGetters.new()
      components = reader.get_workflow_components(wf_filename)
      comp_from = components[proc_name][0]
      return get_comp_out_port_depth(comp_from,out_name)
    end

    def get_comp_out_port_depth(comp,out_name)
      profile = TavernaLite::WorkflowProfile.find_by_workflow_id(comp.workflow_id)
      out = profile.outputs.where(:name=>out_name)[0]
      pd = out.depth.to_s + ':' +out.granular_depth.to_s
      return pd
    end

    def get_comp_in_port_depth(comp,in_name)
      profile = TavernaLite::WorkflowProfile.find_by_workflow_id(comp.workflow_id)
      inpt = profile.inputs.where(:name=>in_name)[0]
      pd = inpt.depth.to_s
      return pd
    end

  end # Class WorkflowComponentsController
end # Module TavernaLite
