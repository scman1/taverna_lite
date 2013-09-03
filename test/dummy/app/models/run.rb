class Run < ActiveRecord::Base
  attr_accessible :creation, :description, :end, :expiry, :run_identification, :start, :state, :user_id, :workflow_id
end
