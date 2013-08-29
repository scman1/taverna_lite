module TavernaLite
  class WorkflowProfile < ActiveRecord::Base
    attr_accessible :author_id, :created, :description, :license_id, :modified, :title, :version
  end
end
