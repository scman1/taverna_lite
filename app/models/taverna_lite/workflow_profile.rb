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
# BioVeL Taverna Lite  is a prototype interface provided to support the
# inspection and modification of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.

module TavernaLite
  class WorkflowProfile < ActiveRecord::Base
    attr_accessible :author_id, :created, :description, :license_id, :modified,
      :title, :version, :workflow_id

    # Each profile will be mapped to a user in the main application
    belongs_to :author, class_name: TavernaLite.author_class

    # Set the user to which the profile is associated before saving
    before_save :set_author

    # Each profile will be mapped to a workflow in the main application
    belongs_to :workflow, class_name: TavernaLite.workflow_class

    # Set the workflow to which the profile is associated before saving
    before_save :set_workflow

    def get_inputs
      sources = {}
      descriptions = {}
      # get the workflow t2flow model
      model = get_model
      # collect the sources and their descriptions
      model.sources().each{|source|
        example_values = source.example_values
        if ((!example_values.nil?) && (example_values.size == 1)) then
          sources[source.name] = example_values[0]
        else
          sources[source.name] = ""
        end
        description_values = source.descriptions
        if ((!description_values.nil?) && (description_values.size == 1)) then
          descriptions[source.name] = description_values[0]
        else
          descriptions[source.name] = ""
        end
      }
      return [sources,descriptions]
    end

    def get_custom_inputs
      # 1 Get custom inputs
      custom_inputs = WorkflowPort.get_custom_ports(workflow.id, 1)
      # 2 Get all inputs
      model = get_model
      # 3 Add missing ports (if any) to the list
      model.sources().each{|source|
        if (custom_inputs).where("name='#{source.name}'").count() == 0 then
          # missing input
          missing_port = WorkflowPort.new()
          missing_port.name = source.name
          missing_port.workflow_id = id
          missing_port.port_type_id = 1          # id of inputs
          missing_port.display_control_id = 1 # default display control
          example_values = source.example_values
          if ((!example_values.nil?) && (example_values.size == 1)) then
            missing_port.sample_value = example_values[0]
          else
            missing_port.sample_value = ""
          end
          custom_inputs << missing_port
        end
      }
      # 4 Return the list of custom inputs
      return custom_inputs
    end

    def get_outputs
      sinks = {}
      descriptions = {}
      # get the workflow t2flow model
      model = get_model
      # collect the sinks and their descriptions
      model.sinks().each{|sink|
        example_values = sink.example_values
        if ((!example_values.nil?) && (example_values.size == 1)) then
          sinks[sink.name] = example_values[0]
        else
          sinks[sink.name] = ""
        end
        description_values = sink.descriptions
        if ((!description_values.nil?) && (description_values.size == 1)) then
          descriptions[sink.name] = description_values[0]
        else
          descriptions[sink.name] = ""
        end
      }
      return [sinks,descriptions]
    end

    def get_custom_outputs
      # 1 Get custom inputs
      custom_outputs = TavernaLite::WorkflowPort.get_custom_ports(workflow.id, 2)
      # 2 Get all inputs
      model = get_model
      # 3 Add missing ports (if any) to the list
      model.sinks().each{|sink|
        if (custom_outputs).where("name='#{sink.name}'").count() == 0 then
          # missing output
          missing_port = TavernaLite::WorkflowPort.new()
          missing_port.name = sink.name
          missing_port.workflow_id = id
          missing_port.port_type_id = 2       # id of outputs
          missing_port.display_control_id = 1 # default display control
          example_values = sink.example_values
          if ((!example_values.nil?) && (example_values.size == 1)) then
            missing_port.sample_value = example_values[0]
          else
            missing_port.sample_value = ""
          end
          custom_outputs << missing_port
        end
      }
      # 4 Return the list of custom inputs
      return custom_outputs
    end

    # get the workflow model
    def get_model
      if FileTest.exists?(workflow.workflow_filename)
        T2Flow::Parser.new.parse(File.open(workflow.workflow_filename))
      else
        nil
      end
    end

    def get_errors
      # need a model for storing error handling information and some benchmarks
      # workflow_id, error_id, error_name, error_pattern, error_message,
      # runs_count, ports_count, most_recent
      # 1 check en results to see if there are results associated to errors
      bad_results = filter_errors
      # 2 Filter all duplicates, present only unique error messages
      #   must open every error file, if different from ones already in leave else
      #   do not add to final list of bad results
      # 3 filter those errors that have been handled i.e. check if error file
      #   contains a recognised error_pattern if it does then remove the error
      #   from set
      # 4 return the rest as unhandled error occurrences
      return bad_results
    end

    def get_runs_with_errors_count
      runs_with_errors =
        Run.where('workflow_id = ?',workflow.id).joins(:results).where('filetype = ?','error').group('run_id').count.count
      return runs_with_errors
    end

    def filter_errors
      bad_results =
        TavernaLite.result_class.where("filetype=? ",'error').joins(:run).where("workflow_id = ?", workflow.id)
      collect = []
      samples = []
      runs = []
      bad_results.each do |ind_error|
        example_value = IO.read(ind_error.result_filename)
        unless samples.include?(example_value)
          collect << ind_error
          samples << example_value
          runs << ind_error.id
        end
      end
      return collect
    end

    def get_error_codes
      error_codes =
        WorkflowError.where('workflow_id = ?',workflow.id)
      unhandled =  unhandled_errors
      return error_codes | unhandled
    end

  def unhandled_errors
    bad_results =
      TavernaLite.result_class.where("filetype=? ",'error').joins(:run).where("workflow_id = ?", workflow.id)
    error_codes =
      TavernaLite::WorkflowError.where('workflow_id = ?',workflow.id)
    collect = []
    samples = []
    runs = []
    bad_results.each do |ind_result|
      is_new = true
      error_codes.each do |ind_error|
        file_content = IO.read(ind_result.result_filename)
        if file_content =~ /#{ind_error.pattern}/m then
          is_new = false
        end
      end
      if is_new then
        example_value = IO.read(ind_result.result_filename)
        # 1 Filer duplicate outputs - Sometimes the same error happens several times
        unless samples.include?(example_value)
          new_error = WorkflowError.new
          new_error.error_code = "E_" + (100000+ind_result.run_id).to_s + "_" + ind_result.name
          new_error.message = "Workflow run produced an error for " + ind_result.name
          new_error.name = ind_result.name + " Error"
          new_error.pattern = example_value
          #if TavernaLite.run_class.exists?(ind_result.run_id)
            # if run still exists assign the run creation date
           # new_error.most_recent = TavernaLite.run_class.find(ind_result.run_id).creation
          #else
            # if run has been deleted assign result creation date
           # new_error.most_recent = ind_result.created_at
          #end
          #new_error.my_experiment_id = my_experiment_id
          #new_error.ports_count = 1
          #new_error.runs_count = 1
          new_error.workflow_id = workflow.id
          collect << new_error
          samples << example_value
          runs << ind_result.id
        end
      end
    end
    return collect
  end

    private
    def set_author
      self.author = TavernaLite.author_class.find(:workflow)
    end
    def set_workflow
      self.workflow = TavernaLite.workflow_class.find(:author)
    end
  end
end
