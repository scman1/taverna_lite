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
  class WorkflowPortsController < ApplicationController
    def save_custom_inputs
      action = params[:commit]
      @workflow = Workflow.find(params[:id])
      @workflow_profile = WorkflowProfile.new()
      @workflow_profile.workflow_id = @workflow.id
      @inputs, @input_desc = @workflow_profile.get_inputs
      if action == 'Save'
        save_inputs
      elsif action == 'Reset'
        reset_inputs
      end
      respond_to do |format|
        format.html {
          redirect_to taverna_lite.edit_workflow_profile_path(@workflow),
            :notice => 'inputs updated'}
        format.json { head :no_content }
       end
    end

    def save_inputs
      @input_desc.each do |indiv_in|
        port_name = indiv_in[0]
        file_for_i = "file_for_"+port_name
        display_i = "display_for_"+port_name
        type_i = "type_for_"+port_name
        description_i = "description_for_"+port_name
        new_name_i = "name_for_"+port_name
        if (params[:file_uploads].include? port_name) &&
            ((params[:file_uploads].include? file_for_i) ||
             (params[:file_uploads][port_name] != ""))
          # verify if customised input exists
          wfps = WorkflowPort.where("port_type_id = ? and name = ? and workflow_id = ?", "1", port_name, @workflow.id)
          if wfps.empty?
            @wfp = WorkflowPort.new()
          else
            @wfp = wfps[0]
          end
          new_name = params[:file_uploads][new_name_i]
          new_description = params[:file_uploads][description_i]
          new_example = params[:file_uploads][port_name]
          t2flow_changes=false
          #get values for customised input
          @wfp.workflow_id = @workflow.id
          @wfp.port_type_id = 1 # 1 = input
          # save only if there are changes, else leave unchanged
          if @wfp.name != new_name
             @wfp.old_name = @wfp.name
             @wfp.name = new_name
             t2flow_changes = true
          end
          if @wfp.description != new_description
            @wfp.old_description = @wfp.description
            @wfp.description = new_description
            t2flow_changes = true
          end
          if new_example != "" && @wfp.example != new_example
            @wfp.old_example = @wfp.example
            @wfp.example = new_example
            t2flow_changes = true
          end
          @wfp.display_control_id = params[:file_uploads][display_i]
          @wfp.example_type_id = params[:file_uploads][type_i]
          if params[:file_uploads].include? file_for_i
            #save file
            @wfp.file_content = params[:file_uploads][file_for_i].tempfile
            @wfp.sample_file =  params[:file_uploads][file_for_i].original_filename
            @wfp.sample_file_type = params[:file_uploads][file_for_i].content_type
          end
          # now need to save changes to t2flow file if t2flow values are changed
          # open the workflow file
          if t2flow_changes
            xmlFile = @workflow.workflow_filename
            writer = T2flowWriter.new
            writer.save_wf_input_annotations(xmlFile, port_name, new_name, new_description, new_example)
          end
          #save the customisation
          @wfp.save
        end
      end
    end

    def reset_inputs
      @input_desc.each do |indiv_in|
        port_name = indiv_in[0]
        wfps = WorkflowPort.where("port_type_id = ? and name = ?", "1", port_name)
        unless wfps.empty?
          @wfp = wfps[0]
          @wfp.delete_files
          @wfp.destroy
        end
      end
    end

    def save_custom_outputs
      action = params[:commit]
      @workflow = Workflow.find(params[:id])
      @workflow_profile = WorkflowProfile.new()
      @workflow_profile.workflow_id = @workflow.id
      # get outputs from the model and any customisation if they exist
      @outputs, @output_desc = @workflow_profile.get_outputs

      selected_tab = params[:selected_tab]
      selected_choice = params[:selected_choice]
      if action == 'Save'
        save_outputs
      elsif action == 'Reset'
        reset_outputs
      end
      respond_to do |format|
        format.html {
          redirect_to taverna_lite.edit_workflow_profile_path(@workflow),
           :notice => 'outputs updated'}
        format.json { head :no_content }
      end
    end

    def save_outputs
      @output_desc.each do |indiv_in|
        port_name = indiv_in[0]
        file_for_i = "file_for_"+port_name
        customise_i = "customise_"+port_name
        display_i = "display_for_"+port_name
        type_i = "type_for_"+port_name
        new_name_i = "name_for_"+port_name
        description_i = "description_for_"+port_name
        if (params[:file_uploads].include? port_name) &&
            ((params[:file_uploads].include? file_for_i) ||
             (params[:file_uploads][port_name] != ""))
          # verify if customised output exists
          wfps = WorkflowPort.where("port_type_id = ? and name = ?", "2", port_name)
          if wfps.empty?
            @wfp = WorkflowPort.new()
          else
            @wfp = wfps[0]
          end
          new_name = params[:file_uploads][new_name_i]
          new_description = params[:file_uploads][description_i]
          new_example = params[:file_uploads][port_name]
          t2flow_changes=false

          #get values for customised output
          @wfp.workflow_id = @workflow.id
          @wfp.port_type_id = 2 # 2 = output
          # save only if there are changes, else leave unchanged
          if @wfp.name != new_name
             @wfp.old_name = @wfp.name
             @wfp.name = new_name
             t2flow_changes = true
          end
          if @wfp.description != new_description
            @wfp.old_description = @wfp.description
            @wfp.description = new_description
            t2flow_changes = true
          end
          if new_example != "" && @wfp.example != new_example
            @wfp.old_example = @wfp.example
            @wfp.example = new_example
            t2flow_changes = true
          end
          @wfp.display_control_id = params[:file_uploads][display_i]
          @wfp.example_type_id = params[:file_uploads][type_i]
          # save file sample file if provided
          if params[:file_uploads].include? file_for_i
            @wfp.file_content = params[:file_uploads][file_for_i].tempfile
            @wfp.sample_file =  params[:file_uploads][file_for_i].original_filename
            @wfp.sample_file_type = params[:file_uploads][file_for_i].content_type
          end
          # now need to save changes to t2flow file if t2flow values are changed
          # open the workflow file
          if t2flow_changes
            xmlFile = @workflow.workflow_filename
            writer = T2flowWriter.new
            writer.save_wf_output_annotations(xmlFile, port_name, new_name, new_description, new_example)
          end
          #save the customisation
          @wfp.save
        end
      end
    end

    def reset_outputs
      @output_desc.each do |indiv_out|
        o_name = indiv_out[0]
        wfps = WorkflowPort.where("port_type_id = ? and name = ?", "2", o_name)
        unless wfps.empty?
          @wfp = wfps[0]
          @wfp.delete_files
          @wfp.destroy
        end
      end
    end

  end
end
