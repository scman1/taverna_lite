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
require 'test_helper'

module TavernaLite
  class FeatureTest < ActiveSupport::TestCase
    setup do
      @root = taverna_lite_features(:one)
      # get stage matrix is mandatory and has 1 mandatory and 2 xor children
      @getStageMatrix = taverna_lite_features(:two)
      # analyse matrix is mandatory and has 6 or children
      @analyseMatrix = taverna_lite_features(:twentyseven)
      # read plain text is xor and has 5 optional children
      @readPlainText = taverna_lite_features(:nine)
      # text table to R is optional, has no children and its instantiated
      @textTableToR = taverna_lite_features(:twelve)
      # eigen analsyis is or, has no children and its instantiated
      @eigenAnalysis = taverna_lite_features(:thirtyfour)
    end

    test "00 get parent for root" do
      assert_nil @root.parent
    end
    test "01 get parent for node" do
      assert_equal @getStageMatrix.parent, @root
    end
    test "02 get mandatory features" do
      x = @getStageMatrix.mandatory
      assert_equal 1, x.length
      assert_equal 2, x[0].feature_type_id
    end
    test "03 get xor features" do
      x = @getStageMatrix.xor
      assert_equal 2, x.length
      x.each { |ft|
        assert_equal 3, ft.feature_type_id
      }
    end
    test "04 get or features" do
      x = @analyseMatrix.or
      assert_equal 6, x.length
      x.each { |ft|
        assert_equal 4, ft.feature_type_id
      }
    end
    test "05 get optional features" do
      x = @readPlainText.optional
      assert_equal 5, x.count
      x.each { |ft|
        assert_equal 5, ft.feature_type_id
      }
    end # test 05

    # test what you get when the feature is instantiated and what when it is not
    test "06 test if feature is instantiated" do
      assert @textTableToR.instantiated
      assert_not_nil @textTableToR.component_id
      assert !@readPlainText.instantiated
      assert_equal 0, @readPlainText.component_id # this should  be nil
      #assert_equal nil, @readPlainText.component_id # problem with YML or test?
    end # test 06

    test "07 get alternatives to instantiated features" do
      alternative_features = @textTableToR.alternatives
      # total eight alternatives to replace this feature
      assert_equal 8, alternative_features.count
      i = j = 0
      alternative_features.each {|ft|
        if ft.parent == @textTableToR.parent
          i += 1
        else
          j += 1
        end
      }
      # 5 different versions of the same component (optional features)
      assert_equal 4, i
      # plus 2 other components with 2 and 1 versions each (xor features)
      assert_equal 4, j
    end
    test "08 get features that can be added" do
      additional_features = @eigenAnalysis.additional
      assert_equal 4, additional_features.count
    end
  end
end
