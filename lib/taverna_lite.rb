require "taverna_lite/engine"

module TavernaLite
  # Make the classes that represents User and Workflow in the application
  # customisable for the engine. This way the classes in the host application
  # may have a different name but will be referenced internally as :author_class
  # and :workflow_class

  mattr_accessor :author_class

  mattr_accessor :workflow_class

  # To save having to call constantize on the author_class and workflow_class
  # results all the time, override the classes getter method inside the
  # TavernaLite module in the lib/taverna_lite.rb file to always call
  # constantize on the saved value before returning the result:
  def self.workflow_class
    @@workflow_class.constantize
  end
  def self.author_class
    @@author_class.constantize
  end

end
