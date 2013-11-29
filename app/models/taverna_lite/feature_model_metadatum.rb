module TavernaLite
  class FeatureModelMetadatum < ActiveRecord::Base
    attr_accessible :address, :creator, :date, :department, :description, :email, :feature_model_id, :organisation, :phone, :reference, :website
  end
end
