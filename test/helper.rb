# Loaded before every set of tests: the assertion notation, and a helper
# that each structure should make available inside its tests.

require 'assay/ae'
require 'assay/ae/should'

module Spectrum::World
  def world_helper
    "helped by the world"
  end
end
