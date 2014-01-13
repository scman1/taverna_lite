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
# * Neither the names of Cardiff University nor The University of Manchester nor
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
module TavernaLite
  class WorkflowPort < ActiveRecord::Base
    attr_accessible :description, :display_control_id, :example, :example_type,
      :example_type_id, :name, :old_description, :old_example, :old_name,
      :order, :port_type_id, :workflow_id, :depth, :granular_depth

    # Each port will be mapped to a workflow_profile in the main application
    belongs_to :workflow_profile

    # After saving the port, save the example file, if provided
    after_save :store_file
    validates :name, :presence => true
    # get a list of all worflow ports
    # type:
    #      1 Inputs
    #      2 Outputs
    def self.get_custom_ports(workflow_id = 1, type = 1)
      @custom_ports = WorkflowPort.where("workflow_id = ? and port_type_id=?",
                                          workflow_id, type)
      return @custom_ports
    end

    #workflow store should be a setting on the host application
    WORKFLOW_STORE = Rails.root.join('public', 'workflow_store')

    def file_content=(file_data)
      unless file_data.blank?
        # store the uploaded data into a private instance variable
        @file_data = file_data
      end
    end

    def sample_file_relative_path
      port_filename = nil
      unless sample_file.nil? then
        port_dir = File.join '/workflow_store', "#{workflow_id}/#{name}"
        port_filename = File.join port_dir, "#{sample_file}"
      end
      return port_filename
    end

    def sample_file_actual_path
      port_filename = nil
      unless sample_file.nil? then
        port_dir = File.join WORKFLOW_STORE, "#{workflow_id}/#{name}"
        port_filename = File.join port_dir, "#{sample_file}"
      end
      return port_filename
    end

    def delete_files
      port_dir = File.join WORKFLOW_STORE, "#{workflow_id}/#{name}"
      FileUtils.rm_rf(port_dir)
    end

    private
    # **************************************************************************
    # verify if there is actually a file to be saved
    def store_file
      if @file_data
        # create the WORKFLOW_STORE Folder if it does not exist
        port_dir = File.join WORKFLOW_STORE, "#{workflow_id}/#{name}"
        FileUtils.mkdir_p port_dir
        port_filename = File.join port_dir, "#{sample_file}"
        # create the file and write the data to the file system
        File.open(port_filename, 'wb') do |f|
          f.write(@file_data.read)
        end
        # ensure that the data is only save once by clearing the cache after savig
        @file_data = nil
      end
    end
  end
end
