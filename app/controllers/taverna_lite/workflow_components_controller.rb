require_dependency "taverna_lite/application_controller"

module TavernaLite
  class WorkflowComponentsController < ApplicationController
    # GET /workflow_components
    # GET /workflow_components.json
    def index
      @workflow_components = WorkflowComponent.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @workflow_components }
      end
    end

    # GET /workflow_components/1
    # GET /workflow_components/1.json
    def show
      @workflow_component = WorkflowComponent.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @workflow_component }
      end
    end

    # GET /workflow_components/new
    # GET /workflow_components/new.json
    def new
      @workflow_component = WorkflowComponent.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @workflow_component }
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
          format.html { redirect_to @workflow_component, notice: 'Workflow component was successfully created.' }
          format.json { render json: @workflow_component, status: :created, location: @workflow_component }
        else
          format.html { render action: "new" }
          format.json { render json: @workflow_component.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /workflow_components/1
    # PUT /workflow_components/1.json
    def update
      @workflow_component = WorkflowComponent.find(params[:id])

      respond_to do |format|
        if @workflow_component.update_attributes(params[:workflow_component])
          format.html { redirect_to @workflow_component, notice: 'Workflow component was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @workflow_component.errors, status: :unprocessable_entity }
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
  end
end
