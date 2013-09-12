require "taverna_lite/engine"

module TavernaLite
  # Make the classes that represents User, Workflow, Run and Result in host
  # application accesible to the engine. This way the classes in the host
  # application may have a different names but will be referenced by the engine
  # as :author_class, :workflow_class, :run_class and :result_class

  mattr_accessor :author_class

  mattr_accessor :workflow_class

  mattr_accessor :run_class

  mattr_accessor :result_class

  # To save having to call constantize on theresults from the accessor classes
  # all the time, override the classes getter method inside the TavernaLite
  # module to always call constantize on the saved value before returning the
  # result:
  def self.workflow_class
    @@workflow_class.constantize
  end
  def self.author_class
    @@author_class.constantize
  end
  def self.run_class
    @@run_class.constantize
  end
  def self.result_class
    @@result_class.constantize
  end
end
