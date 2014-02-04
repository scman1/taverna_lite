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

    # GET /workflow_ports
    # GET /workflow_ports.json
    def index
      @workflow_ports = WorkflowPort.order(:workflow_id)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @workflow_ports }
      end
    end

    # GET /workflow_ports/1/edit
    def edit
      @workflow_port = WorkflowPort.find(params[:id])
    end

    # PUT /workflow_ports/1
    # PUT /workflow_ports/1.json
    def update
      @workflow_port = WorkflowPort.find(params[:id])

      respond_to do |format|
        if @workflow_port.update_attributes(params[:workflow_port])
          format.html { redirect_to :workflow_ports, :notice => 'Workflow port was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @workflow_port.errors, :status => :unprocessable_entity }
        end
      end
    end

    def save_custom_inputs
      action = params[:commit]
      @workflow = Workflow.find(params[:id])
      @workflow_profile = WorkflowProfile.find_by_workflow_id(params[:id])
      @workflow_profile.workflow_id = @workflow.id
      @ports_list = @workflow_profile.inputs

      if action == 'Save'
        save_ports
      elsif action == 'Reset'
        reset_ports
      end
      respond_to do |format|
        format.html {
          redirect_to taverna_lite.edit_workflow_profile_path(@workflow),
            :notice => 'inputs updated'}
        format.json { head :no_content }
       end
    end

    def save_custom_outputs
      action = params[:commit]
      @workflow = Workflow.find(params[:id])
      @workflow_profile = WorkflowProfile.find_by_workflow_id(params[:id])
      @workflow_profile.workflow_id = @workflow.id
      # get outputs from the model and any customisation if they exist
      @ports_list = @workflow_profile.outputs

      selected_tab = params[:selected_tab]
      selected_choice = params[:selected_choice]
      if action == 'Save'
        save_ports(2)
      elsif action == 'Reset'
        reset_ports(2)
      end
      respond_to do |format|
        format.html {
          redirect_to taverna_lite.edit_workflow_profile_path(@workflow),
           :notice => 'outputs updated'}
        format.json { head :no_content }
      end
    end

    def save_ports(port_type=1)
      @ports_list.each do |indiv_in|
        port_name = indiv_in.name
        file_for_i = "file_for_"+port_name
        display_i = "display_for_"+port_name
        type_i = "type_for_"+port_name
        description_i = "description_for_"+port_name
        example_i = "description_for_"+port_name
        new_name_i = "name_for_"+port_name
        show_i = "show_"+port_name
        delete_i = "delete_"+port_name
        delete_port = params[:port_annotations][delete_i] == '1'
        unless delete_port then
          # verify if customised input exists
          condition = "port_type_id = ? and name = ? and workflow_id = ?"
          wfps = WorkflowPort.where(condition, port_type, port_name, @workflow.id)
          wf_prof =  WorkflowProfile.find_by_workflow_id(@workflow.id)
          if wfps.empty?
            @wfp = WorkflowPort.new()
          else
            @wfp = wfps[0]
          end

          new_name = params[:port_annotations][new_name_i]
          new_description = params[:port_annotations][description_i]
          new_example = params[:port_annotations][port_name]
          t2flow_changes=false

          #get values for customised input
          @wfp.workflow_id = @workflow.id
          @wfp.workflow_profile_id = wf_prof.id
          @wfp.port_type_id = port_type # 1 = input
          # always save even if there are no changes
          @wfp.old_name = port_name
          @wfp.name = new_name
          @wfp.old_description = @wfp.description
          @wfp.description = new_description
          @wfp.old_example = @wfp.example
          @wfp.example = new_example
          @wfp.display_control_id = params[:port_annotations][display_i]
          @wfp.example_type_id = params[:port_annotations][type_i]
          @wfp.show = params[:port_annotations][show_i]
          if params[:port_annotations].include? file_for_i
            #save file
            @wfp.file_content = params[:port_annotations][file_for_i].tempfile
            @wfp.sample_file =  params[:port_annotations][file_for_i].original_filename
            @wfp.sample_file_type = params[:port_annotations][file_for_i].content_type
          end
          # now need to save changes to t2flow file
          xmlFile = @workflow.workflow_filename
          writer = T2flowWriter.new
          writer.save_wf_port_annotations(xmlFile, port_name, new_name, new_description, new_example,port_type)
          #save the customisation
          @wfp.save
        else
          # delete the port from the file
          xmlFile = @workflow.workflow_filename
          writer = T2flowWriter.new
          writer.remove_wf_port(xmlFile, port_name,port_type)
          # delete the port from the db
          wfps = WorkflowPort.where("port_type_id = ? and name = ? and workflow_id = ?", port_type, port_name, @workflow.id)
          unless wfps.empty?
           @wfp = wfps[0]
           @wfp.destroy
          end
        end
      end
    end

    def reset_ports(port_type=1)
      @port_desc_list.each do |indiv_in|
        port_name = indiv_in[0]
        wfps = WorkflowPort.where("port_type_id = ? and name = ? and workflow_id = ?", port_type, port_name, @workflow.id)
        unless wfps.empty?
          @wfp = wfps[0]
          unless @wfp.old_name.nil?
            old_name = @wfp.old_name
          end
          unless @wfp.old_description.nil?
            old_description = @wfp.old_description
          end
          unless @wfp.old_example.nil?
            old_example = @wfp.old_example
          end

          xmlFile = @workflow.workflow_filename
          writer = T2flowWriter.new
          writer.save_wf_port_annotations(xmlFile, port_name, old_name, old_description, old_example,port_type)
          @wfp.delete_files
          @wfp.sample_file = ""
          @wfp.sample_file_type = ""
          @wfp.old_name = ""
          @wfp.old_description = ""
          @wfp.old_example = ""
          @wfp.name = old_name
          @wfp.description = old_description
          @wfp.example = old_example
          if port_type==1
            @wfp.display_control_id = 1 #default to value or file
          else
            @wfp.display_control_id = 2 #default to value or file
          end
          @wfp.save
        end
      end
    end
    # download a sample file
    def download
      @workflow_port = WorkflowPort.find(params[:id])
      path = @workflow_port.sample_file_actual_path
      filetype = MIME::Types.type_for(path)
      send_file path, :type=> filetype, :name => @workflow_port.sample_file
    end
    # add a set of workflow outputs
    def add_outputs
      @workflow = TavernaLite.workflow_class.find(params[:id])
      action = params[:commit]
      processor_name =  params[:add_outputs][:processor_name]
      selected_tab = params[:selected_tab]
      selected_choice = params[:selected_choice]
      xmlFile = @workflow.workflow_filename
      writer = T2flowWriter.new
      processor_ports = params[:add_outputs]["#{processor_name}_ports"]
      unless processor_ports.nil?
        # add a new workflow port
        the_ports = processor_ports.split(",")
        the_ports.each do |proc_port|
          customise =  params[:add_outputs]["add_#{proc_port}"]
          if customise == "1"
            port_name=params[:add_outputs]["name_for_port_#{proc_port}"]
            port_description=params[:add_outputs]["description_for_port_#{proc_port}"]
            port_example=params[:add_outputs]["example_for_port_#{proc_port}"]
            # pass the correct depth and granular depth
            port_depth = params[:add_outputs]["depth_for_port_#{proc_port}"]
            port_granular = params[:add_outputs]["granular_for_port_#{proc_port}"]
            writer.add_wf_port(xmlFile, processor_name, proc_port, port_name,
              port_description, port_example, 2, port_depth, port_granular)
            wfp = WorkflowPort.new()
            wfp.name = port_name
            wfp.description = port_description
            wfp.example = port_example
            wfp.workflow_id = @workflow.id
            wfp.workflow_profile_id = WorkflowProfile.find_by_workflow_id(@workflow.id).id
            wfp.port_type_id = 2
            wfp.show = 1  # Always show new ports
            wfp.save
            logger.info "ADD OUTS-----------------------------------------------"
            logger.info params
            logger.info action
            logger.info "FROM "+ processor_name
            logger.info "ALL PORTS: " + processor_ports
            logger.info "WORKFLOW FILE: " + xmlFile
            logger.info "PROCESSOR PORT " + proc_port
            logger.info "NAME FOR PORT " + port_name
            logger.info "DESC FOR PORT " + port_description
            logger.info "EXAM FOR PORT " + port_example
            logger.info "ADD ENDS -----------------------------------------------"
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'processor updated'}
        format.json { head :no_content }
      end
    end
  end
end
