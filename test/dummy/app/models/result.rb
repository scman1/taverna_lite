class Result < ActiveRecord::Base
  attr_accessible :depth, :filepath, :filetype, :name, :run_id
  belongs_to :run
end
