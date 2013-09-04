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
  class WorkflowErrorsController < ApplicationController

   def save_custom_errors
      action = params[:commit]
      @workflow = Workflow.find(params[:id])
      selected_tab = params[:selected_tab]
      selected_choice = params[:selected_choice]

      if action == 'Save'
        save_errors
      elsif action == 'Reset'
        reset_errors
      end
      respond_to do |format|
        format.html { redirect_to taverna_lite.edit_workflow_profile_path(@workflow),
                        :notice => 'Workflow errors updated '}
        format.json { head :no_content }
      end
    end

    def save_errors
      error_codes=params[:file_uploads]
      codes_only = []
      # get just the codes
      error_codes.each do |ecode,value|
        if ecode.exclude?('id_for_') && ecode.exclude?('code_for_') && ecode.exclude?('name_for_') && ecode.exclude?('message_for_') && ecode.exclude?('pattern_for_')
          codes_only << ecode
        end
      end
      # check each code to see if it is new and if it is to be saved
      codes_only.each do |ecode|
        id_for_e      = 'id_for_'+ecode
        code_for_e    = 'code_for_'+ecode
        name_for_e    = 'name_for_'+ ecode
        message_for_e = 'message_for_'+ ecode
        pattern_for_e = 'pattern_for_' + ecode
        # customise this error?
        if (error_codes[ecode] == "1") then
          # verify if customised error exists
          wfec = WorkflowError.where("error_code = ?", ecode)
          if wfec.empty?
            wfe = WorkflowError.new()
          else
            wfe = wfec[0]
          end
          # get values for customised output
          wfe.workflow_id      = @workflow.id
          wfe.error_code       = error_codes[code_for_e]
          wfe.name             = error_codes[name_for_e]
          wfe.pattern          = error_codes[pattern_for_e]
          wfe.message          = error_codes[message_for_e]
          #save the customisation
          wfe.save
        elsif error_codes[ecode] == "0"
          # reset error customisation
          wfec = WorkflowError.where("error_code = ?", ecode)
          unless wfec.empty?
            wfe = wfec[0]
            wfe.destroy
          end
        end
      end
    end

    def reset_errors
      error_codes=params[:file_uploads]
      codes_only = []
      # get just the codes
      error_codes.each do |ecode,value|
        if ecode.exclude?('id_for_') && ecode.exclude?('code_for_') && ecode.exclude?('name_for_') && ecode.exclude?('message_for_') && ecode.exclude?('pattern_for_')
          codes_only << ecode
        end
      end
      codes_only.each do |indiv_err|
        wfer = WorkflowError.where("error_code = ?", indiv_err)
        unless wfer.empty?
          wfe = wfer[0]
          wfe.destroy
        end
      end
    end
    
  end
end
