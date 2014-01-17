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

require 'tsort'

module TavernaLite
  class WorkflowProfile < ActiveRecord::Base
    attr_accessible :author_id, :created, :description, :license_id, :modified,
      :title, :version, :workflow_id

    # Each profile will be mapped to a user in the main application
    belongs_to :author, :class_name => TavernaLite.author_class

    # Each profile will be mapped to a workflow in the main application
    belongs_to :workflow, :class_name => TavernaLite.workflow_class

    # each profile can have several ports
    has_many :workflow_ports, :dependent => :destroy

    def inputs
      ports =  workflow_ports.where(:port_type_id=>1)
      if ports.nil? or ports.blank?
        ports = get_custom_inputs
      end
      return ports
    end

    def outputs
      ports = workflow_ports.where(:port_type_id=>2)
      if ports.nil? or ports.blank?
        ports = get_custom_outputs
      end
      return ports
    end

    def get_custom_inputs
      get_customised_ports(1)
    end

    def get_custom_outputs
      get_customised_ports(2)
    end
    def get_customised_ports(port_type = 1)
      # 1 Get custom inputs
      custom_ports = WorkflowPort.get_custom_ports(workflow.id, port_type)
      # 2 Get all inputs
      model = get_model
      # 3 Add missing ports (if any) to the list
      if port_type == 1
        ports_list = model.sources()
      else
        ports_list = model.sinks()
      end

      ports_list.each{|port_x|
        if (custom_ports).where("name='#{port_x.name}'").count() == 0 then
          # missing input
          missing_port = WorkflowPort.new()
          missing_port.name = port_x.name
          missing_port.workflow_id = workflow.id
          missing_port.workflow_profile_id = self.id
          missing_port.port_type_id = port_type       # id of inputs
          missing_port.display_control_id = 1         # default display control
          missing_port.show = true                    # always show
          example_values = port_x.example_values
          if ((!example_values.nil?) && (example_values.size == 1)) then
            missing_port.example = example_values[0]
          else
            missing_port.example = "Not Provided"
          end
          descriptions = port_x.descriptions
          if ((!descriptions.nil?) && (descriptions.size == 1)) then
            missing_port.description = descriptions[0]
          else
            missing_port.description = "Not Provided"
          end
          missing_port.old_name = ""
          missing_port.old_description = ""
          missing_port.old_example = ""
          missing_port.show = true
          missing_port.save
        end
      }
      # 4 Return the list of custom inputs
      return custom_ports
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

    def processors
      # get the workflow t2flow model
      wf_model = get_model
      processor_names = get_processors_order(wf_model)
      in_order = []
      processor_names.each do |a_processor|
        wf_model.processors.each do |nth_processor|
          if a_processor == nth_processor.name
            in_order << nth_processor
          end
        end
      end
      # collect the workflow processors and their descriptions
      #return ordered_processors
      # temporarily disable this because it creates infinite loop
      return in_order
    end

    def get_processors_order(wf_model)
      nodes_hash = {}
      # Build the hash of graph nodes, something like:
      # {'display'=>[],
      #  'display_csv'=>[],
      #  'display_trans'=>[],
      #  'display_trans01'=>[],
      #  'generate_matrix'=>['display','display_csv','display_trans','display_trans01'],
      #  'getstages'=>['Interaction','Interaction_2'],
      #  'Interaction'=>['generate_matrix'],
      #  'Interaction_2'=>['generate_matrix'],
      #  'Message'=>['Interaction'],
      #  'parse_table'=>['generate_matrix','getstages'],
      #  'SelectRecruitmentStages'=>['Interaction_2']
      #  }

      wf_model.datalinks.each do |dl|
        proc_s = ""
        input = ""
        if (dl.source =~ /:/)
          # comes from another processor output
          proc_s =  dl.source.split(':')[0]
        end
        proc_e = ""
        if (dl.sink =~ /:/)
          # puts "has a colon"
          proc_e =  dl.sink.split(':')[0]
        end
        unless proc_s == ""
          if nodes_hash.include?(proc_s)
            unless proc_e ==""
              nodes_hash[proc_s] << proc_e
            end
          else
            unless proc_e ==""
              nodes_hash[proc_s] = [proc_e]
            else
              nodes_hash[proc_s] = []
            end
          end
        end
      end
      # NEED TO ADD A HASH KEY POINTING TO EMPTY ARRAY WHEN A PROCESSOR OUTPUT
      # IS NOT LINKED TO ANYTHING. OTHERWISE TSORT WILL NOT WORK
      keys = []
      nodes = []
      nodes_hash.each do |k,node|
        keys << k
        nodes = nodes + node
      end
      missing_keys = nodes - keys
      missing_keys.each do |miss|
        nodes_hash[miss] = []
      end
      # tsort returns a topologically sorted array of nodes. The array is sorted from
      # children to parents, i.e. the first element has no child and the last node has
      # no parent.
      sorted_array = nodes_hash.tsort
      # return the sorted array in reverse order
      sorted_array.reverse
    end
  end
end

class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
      fetch(node).each(&block)
  end
end
