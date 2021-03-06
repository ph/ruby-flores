# encoding: utf-8
# This file is part of ruby-flores.
# Copyright (C) 2015 Jordan Sissel
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
require "flores/rspec"
require "flores/random"

RSpec.configure do |config|
  Flores::RSpec.configure(config)
  Kernel.srand config.seed

  # Demonstrate the wonderful Analyze formatter
  config.add_formatter("Flores::RSpec::Formatters::Analyze")
end

describe "a random number" do
  analyze_results

  context "between 0 and 200 inclusive" do
    let(:number) { Flores::Random.number(0..200) }
    stress_it "should be less than 100" do
      expect(number).to(be < 100)
    end
  end
end
