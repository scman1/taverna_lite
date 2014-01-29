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
      @workflow_profile =
        WorkflowProfile.find_by_author_id_and_workflow_id(@author.id,@workflow.id)
      if @workflow_profile == nil
        @workflow_profile =
          WorkflowProfile.new(:author_id => @author.id, :workflow_id => @workflow.id)
        @workflow_profile.save
      end
      # gets inputs, with customisation if they exist
      @inputs = @workflow_profile.inputs
      @input_names = []
      @inputs.each {|p| @input_names << p.name}
      # gets outputs, with customisation if they exist
      @outputs = @workflow_profile.outputs
      @output_names = []
      @outputs.each {|p| @output_names << p.name}
      #get errors and error codes
      @workflow_errors = @workflow_profile.get_errors
      @workflow_error_codes = @workflow_profile.get_error_codes
      #get the workflow processors to display structure
      @processors = @workflow_profile.processors
      @processor_names = []
      @processors.each {|p| @processor_names << p.name}
      @wf_components = get_workflow_components(@workflow_profile.id) # need to move the definition of this method out of controller
      @component_alternatives = @component_additionals = nil
      unless @wf_components.nil? || @wf_components.count == 0
        @component_swaps = get_component_swaps(@wf_components) # need to move the definition of this method out of controller
        @component_additionals = get_component_additionals(@wf_components) # need to move the definition of this method out of controller
      end
      # get all the processors outputs to enable add ouput
      @processor_ports = get_processor_ports(@workflow.id) # need to move the definition of this method out of controller
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
      writer = T2flowWriter.new
      writer.save_wf_annotations(xmlFile, author, description, title, name)
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
      wf_file = workflow_profile.workflow.workflow_filename
      #t2flow does not give this info so need to use t2flow_getters
      wf_reader = T2flowGetters.new
      return components_list = wf_reader.get_workflow_components(wf_file)
    end

    # Get the registered alternative components from a given list of components
    def get_component_swaps(wf_components)
      component_swaps = {}
      wf_components.each do |component|
        unless component[1][1].nil? then
          proc_name = component[0]
          c_name = component[1][0].name # the name of the component
          # need to find alternatives using the version, family and registry
          c_version = component[1][0].version
          c_family = component[1][0].family
          c_registry = component[1][0].registry
          # get component from DB
          wfc_db = TavernaLite::WorkflowComponent.find_by_name_and_family_and_registry_and_version(c_name,
            c_family, c_registry, c_version)
          # find alternatives registered in DB
          unless wfc_db.nil?()
            comp_feature = TavernaLite::Feature.where(:component_id=>wfc_db.id)[0]
            unless comp_feature.nil?
              alt_features = comp_feature.alternatives
              unless alt_features.nil?
                component_swaps[proc_name] = []
                alt_features.each { |af|
                  a_wfc = TavernaLite::WorkflowComponent.find(af.component_id)
                  wf =  TavernaLite.workflow_class.find(a_wfc.workflow_id)
                  component_swaps[proc_name]<<[a_wfc]
                }
              end
            end
          end
        end
      end
      component_swaps = format_additionals_for_output(component_swaps)
      return component_swaps
    end

    # Get the registered components which can be added based on the list
    # of components already in the workflow
    def get_component_additionals(wf_components)
      comp_add = {}
      wf_components.each { |component|
        unless component[1][1].nil? then
          proc_name = component[0]
          comp = component[1][0]
          c_name = component[1][0].name # the name of the component
          # need to find components that can be connected to this
          # component outputs
          c_version = component[1][0].version
          c_family = component[1][0].family
          c_registry = component[1][0].registry
          # get components from DB
          wfc_db = TavernaLite::WorkflowComponent.find_by_name_and_family_and_registry_and_version(c_name,
            c_family, c_registry, c_version)
          # find components registered in DB
          unless wfc_db.nil?()
            comp_add[proc_name]=[]
            profile = TavernaLite::WorkflowProfile.find_by_workflow_id(wfc_db.workflow_id)
            comp_outs_set = (profile.outputs.each.collect {|x| x.example_type_id }).to_set
            comp_outs = profile.outputs
            wfprofs = TavernaLite::WorkflowProfile.all
            wfprofs.each { |prof|
             comp_ins_set = (prof.inputs.each.collect {|x| x.example_type_id}).to_set
             if comp_ins_set.subset?(comp_outs_set)
               # need to identify which are the inputs that can be used to
               # link the component
               a_wfc = TavernaLite::WorkflowComponent.find_by_workflow_id(prof.workflow_id)
               ports_to = []
               comp_ins_set.each { |intype|
                 # for now try type matching only
                 prof.inputs.where(:example_type_id=>intype).each { |in_port|
                   ports_to << comp_outs.where(:example_type_id=>intype).collect{|x|
                     ("New_Processor_Name:"+in_port.name + ","+ proc_name+":" + x.name+","+in_port.depth.to_s).split(",")}
                 }
               }
               unless (a_wfc.nil?)
                 comp_add[proc_name]<<[a_wfc,ports_to]
               end
             end
            }
          end
        end
      }
      comp_add = format_additionals_for_output(comp_add)
      return comp_add
    end

    # Retuns a structure whit the additional components infor ready to be
    # inserted in the UI
    def format_additionals_for_output(comps_struct)
      add_struct={}
      comps_struct.each {|wf_proc,comps|
        add_struct[wf_proc]=[]
        ver_list = {}
        prev_comp = prev_ver = prev_fam = prev_reg = prev_id =
        prev_des = prev_tit = prev_outs = nil
        comps.each do |item|
          current_comp = item[0].name
          current_ver = item[0].version
          current_fam = item[0].family
          current_reg = item[0].registry
          current_des = item[0].workflow.description
          current_tit = item[0].workflow.title
          current_id = item[0].id
          current_outs = item[1]
          if ver_list.empty? then
            prev_comp = current_comp
            prev_ver = current_ver
            prev_fam = current_fam
            prev_reg = current_reg
            prev_id = current_id
            prev_des =  current_des
            prev_tit = current_tit
            prev_outs = current_outs
            ver_list = {prev_ver=>prev_id}
          elsif (current_comp == prev_comp && current_fam == prev_fam && current_reg == prev_reg)  then
            ver_list[current_ver] = current_id
          else
            add_struct[wf_proc]<< {
              :family => prev_fam,
              :name => prev_comp,
              :registry => prev_reg,
              :versions => ver_list,
              :description => prev_des,
              :title => prev_tit,
              :connects_to => prev_outs
            }
            prev_comp = current_comp
            prev_ver = current_ver
            prev_fam = current_fam
            prev_reg = current_reg
            prev_id = current_id
            prev_des =  current_des
            prev_tit = current_tit
            prev_outs = current_outs
            ver_list = {prev_ver=>prev_id}
          end
        end
        add_struct[wf_proc]<< {
              :family => prev_fam,
              :name => prev_comp,
              :registry => prev_reg,
              :versions => ver_list,
              :description => prev_des,
              :title => prev_tit,
              :connects_to => prev_outs
        }
      }
      return add_struct
    end
    # Read the workflow file and get all available workflow ports
    def get_processor_ports(workflow_id)
      wf =  TavernaLite.workflow_class.find(workflow_id)
      wfreader = T2flowGetters.new()
      wfreader.get_processors_outputs(wf.workflow_filename)
    end

    # Save processor annotations and name changes to workflow file
    def annotate_processor
      @workflow = TavernaLite.workflow_class.find(params[:id])
      action = params[:commit]
      if action == "remove"
        processor_name = params[:processor_name]
        writer = T2flowWriter.new
        writer.remove_processor(@workflow.workflow_filename,processor_name)
        TavernaLite::WorkflowProfile.find_by_workflow_id(@workflow.id).destroy
      else
      # works for now but will need changes if saving all at once is enabled
      processor_name =  params[:processor_annotations][:processor_name]
      new_name =  params[:processor_annotations]["name_for_#{processor_name}"]
      description = params[:processor_annotations]["description_for_#{processor_name}"]
      replace_comp = params[:processor_annotations]["replace_#{processor_name}"]
      replace_id = params[:processor_annotations]["replace_#{replace_comp}_ver"]
      selected_tab = params[:selected_tab]
      selected_choice = params[:selected_choice]
      if action == "Reset" then description = "" end
      xmlFile = @workflow.workflow_filename
      writer = T2flowWriter.new
      writer.save_wf_processor_annotations(xmlFile, processor_name, new_name, description)
      comp_in_proc_id = params[:component_id]
      end
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow), :notice => 'processor updated'}
        format.json { head :no_content }
      end
    end
  end #Class: WorkflowProfilesController
end # Module: TavernaLite
