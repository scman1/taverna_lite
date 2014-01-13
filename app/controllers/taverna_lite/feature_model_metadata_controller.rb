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
  class FeatureModelMetadataController < ApplicationController
    # GET /feature_model_metadata
    # GET /feature_model_metadata.json
    def index
      @feature_model_metadata = FeatureModelMetadatum.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @feature_model_metadata }
      end
    end

    # GET /feature_model_metadata/1
    # GET /feature_model_metadata/1.json
    def show
      @feature_model_metadatum = FeatureModelMetadatum.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @feature_model_metadatum }
      end
    end

    # GET /feature_model_metadata/new
    # GET /feature_model_metadata/new.json
    def new
      @feature_model_metadatum = FeatureModelMetadatum.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @feature_model_metadatum }
      end
    end

    # GET /feature_model_metadata/1/edit
    def edit
      @feature_model_metadatum = FeatureModelMetadatum.find(params[:id])
    end

    # POST /feature_model_metadata
    # POST /feature_model_metadata.json
    def create
      @feature_model_metadatum = FeatureModelMetadatum.new(params[:feature_model_metadatum])

      respond_to do |format|
        if @feature_model_metadatum.save
          format.html { redirect_to @feature_model_metadatum, :notice => 'Feature model metadatum was successfully created.' }
          format.json { render :json => @feature_model_metadatum, :status => :created, :location => @feature_model_metadatum }
        else
          format.html { render :action => "new" }
          format.json { render :json => @feature_model_metadatum.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /feature_model_metadata/1
    # PUT /feature_model_metadata/1.json
    def update
      @feature_model_metadatum = FeatureModelMetadatum.find(params[:id])

      respond_to do |format|
        if @feature_model_metadatum.update_attributes(params[:feature_model_metadatum])
          format.html { redirect_to @feature_model_metadatum, :notice => 'Feature model metadatum was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @feature_model_metadatum.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /feature_model_metadata/1
    # DELETE /feature_model_metadata/1.json
    def destroy
      @feature_model_metadatum = FeatureModelMetadatum.find(params[:id])
      @feature_model_metadatum.destroy

      respond_to do |format|
        format.html { redirect_to feature_model_metadata_url }
        format.json { head :no_content }
      end
    end
  end
end
