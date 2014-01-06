# Copyright (c) 2012-2013 Cardiff University, UK.
# Copyright (c) 2012-2013 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the names of The University of Manchester nor Cardiff University nor
#   the names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Authors
#     Abraham Nieva de la Hidalga
#
# Synopsis
#
# BioVeL Taverna Lite is a prototype interface provided to support the
# inspection and modification of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.

module TavernaLite
  class Feature < ActiveRecord::Base
    attr_accessible :cardinality_lower_bound, :cardinality_upper_bound,
    :component_id, :feature_model_id, :feature_type_id, :name, :parent_node_id
    def parent
      if parent_node_id == 0
        return nil
      end
      Feature.find(parent_node_id)
    end
    # if instantiated, feature must point to a component
    def instantiated
      return !component_id.nil? && component_id != 0
    end
    def mandatory
      Feature.find_all_by_parent_node_id_and_feature_type_id(id,2)
    end
    def xor
      Feature.find_all_by_parent_node_id_and_feature_type_id(id,3)
    end
    def or
      Feature.find_all_by_parent_node_id_and_feature_type_id(id,4)
    end
    def optional
      Feature.find_all_by_parent_node_id_and_feature_type_id(id,5)
    end
    def alternatives
      feature_alternatives = []
      unless instantiated
        return feature_alternatives
      end
      # get all siblings if node is optional
      if self.feature_type_id == 5
        parent.optional.each{ |ft|
          unless ft.id == self.id
            feature_alternatives << ft
          end
        }
      end
      # get alternatives if parent is xor
      if parent.feature_type_id == 3
        parent.parent.xor.each { |xoft|
          unless xoft==parent
            xoft.optional.each {|ft|
              feature_alternatives << ft
            }
          end
        }
      end
      return feature_alternatives
    end
    def additional
      feature_additionals =[]
      unless instantiated
        return feature_additionals
      end
      # get all siblings if node is optional
      if self.feature_type_id == 5
        parent.optional.each{ |ft|
          unless ft.id == self.id
            feature_additionals << ft
          end
        }
      end
      # get additionals if parent is or
      if parent.feature_type_id == 4
        parent.parent.or.each { |oft|
          unless oft==parent
            oft.optional.each {|ft|
              feature_additionals << ft
            }
          end
        }
      end
      return feature_additionals
    end
  end
end
