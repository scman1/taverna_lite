class Result < ActiveRecord::Base
  attr_accessible :depth, :filepath, :filetype, :name, :run_id
  belongs_to :run
  RESULT_STORE = Rails.root.join('public', 'result_store')
  # define the path where workflow files will be written to:
  def result_filename
    File.join RESULT_STORE, self.filepath, "value"
  end
end
