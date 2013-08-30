module TavernaLite
  class WorkflowProfile < ActiveRecord::Base
    attr_accessible :author_id, :created, :description, :license_id, :modified, 
      :title, :version
    belongs_to :author, class_name: TavernaLite.author_class
    # Before saving the workflow_profile, set the user to which it has been
    # associated
    before_save :set_author
    private
    def set_author
      self.author = TavernaLite.author_class.find(self.author_id)
    end 
  end
end
