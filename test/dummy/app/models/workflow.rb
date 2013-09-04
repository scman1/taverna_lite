class Workflow < ActiveRecord::Base
  attr_accessible :author, :description, :is_shared, :my_experiment_id, :name, 
  :title, :user_id, :workflow_file, :wf_file

  # a workflow can have many runs
  has_many :runs

  # after the workflow details have been written to the DB
  # write the workflow file to the filesystem
  after_save :store_wffile

  # Validate the workflow file
  validate :validate_file_is_included, :on=>:create
  validate :validate_file_is_t2flow

  def run_count
    return runs.count
  end

  def get_runs_with_errors_count
    runs_with_errors =
      Run.where('workflow_id = ?',id).joins(:results).where('filetype = ?','error').group('run_id').count.count
    return runs_with_errors
  end

  # Validate that there is a file is selected
  def validate_file_is_included
    if workflow_file.nil? && @file_data.nil?
      errors.add :workflow_file,
                 " missing, please select a file and try again"
    end
  end

  #validate that the file is a workflow
  def validate_file_is_t2flow
    if !@file_data.nil? && !get_details_from_model
      errors.add :workflow_file,
                 " \"" + @file_data.original_filename +
                 "\" is not a valid taverna workflow file (t2flow)"
    end
  end

  WORKFLOW_STORE = Rails.root.join('public', 'workflow_store')

  def workflow_filename
    File.join WORKFLOW_STORE, "#{id}" , "#{workflow_file}"
  end

  # use t2flow gem to get the workflow details
  def get_details_from_model(authorname="Undefined")
    file_OK = false
    if @file_data
      begin
        model = T2Flow::Parser.new.parse(@file_data)
        @file_data.rewind
        if !model.nil?
          self.name = model.name
          if model.annotations.titles.join.to_s != ""
            self.title = model.annotations.titles.join.to_s
          else
            self.title = "No title provided"
          end
          if model.annotations.authors.join.to_s != ""
            self.author = model.annotations.authors.join.to_s
          else
            self.author = authorname
          end
          self.description = model.annotations.descriptions.join.to_s
        end
        file_OK = true
      rescue
        file_OK = false
      ensure
        @file_data.rewind
        return file_OK
      end
    end
  end
  # when data is assigned via the upload, store the data in a
  # variable for later and assing the file name to workflow_file
  def wf_file=(file_data)
    unless file_data.blank?
      # store the uploaded data into a private instance variable
      @file_data = file_data
      # set the value of workflow file to that of the original
      # workflow file name
      self.workflow_file = file_data.original_filename
    end
  end

  private
  #the store wffile method is called after the details are saved
  def store_wffile
    # verify if there is actually a file to be saved
    if @file_data
      # create the WORKFLOW_STORE Folder if it does not exist
      FileUtils.mkdir_p File.join WORKFLOW_STORE, "#{id}"
    # create the file and write the data to the file system
      File.open(workflow_filename, 'wb') do |f|
        f.write(@file_data.read)
      end
      # ensure that the data is only save once by clearing the cache after savig
      @file_data = nil
    end
  end
end
