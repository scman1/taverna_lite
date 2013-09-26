require_dependency "taverna_lite/application_controller"

module TavernaLite
  class AlternativeComponentsController < ApplicationController
    # GET /alternative_components
    # GET /alternative_components.json
    def index
      @alternative_components = AlternativeComponent.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @alternative_components }
      end
    end

    # GET /alternative_components/1
    # GET /alternative_components/1.json
    def show
      @alternative_component = AlternativeComponent.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @alternative_component }
      end
    end

    # GET /alternative_components/new
    # GET /alternative_components/new.json
    def new
      @alternative_component = AlternativeComponent.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @alternative_component }
      end
    end

    # GET /alternative_components/1/edit
    def edit
      @alternative_component = AlternativeComponent.find(params[:id])
    end

    # POST /alternative_components
    # POST /alternative_components.json
    def create
      @alternative_component = AlternativeComponent.new(params[:alternative_component])

      respond_to do |format|
        if @alternative_component.save
          format.html { redirect_to @alternative_component, notice: 'Alternative component was successfully created.' }
          format.json { render json: @alternative_component, status: :created, location: @alternative_component }
        else
          format.html { render action: "new" }
          format.json { render json: @alternative_component.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /alternative_components/1
    # PUT /alternative_components/1.json
    def update
      @alternative_component = AlternativeComponent.find(params[:id])

      respond_to do |format|
        if @alternative_component.update_attributes(params[:alternative_component])
          format.html { redirect_to @alternative_component, notice: 'Alternative component was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @alternative_component.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /alternative_components/1
    # DELETE /alternative_components/1.json
    def destroy
      @alternative_component = AlternativeComponent.find(params[:id])
      @alternative_component.destroy

      respond_to do |format|
        format.html { redirect_to alternative_components_url }
        format.json { head :no_content }
      end
    end
  end
end
