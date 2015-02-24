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
require "flores/namespace"
require "rspec/core/formatters/base_text_formatter"

Flores::RSpec::Formatters::Analyze = Class.new(RSpec::Core::Formatters::BaseTextFormatter) do
  RSpec::Core::Formatters.register self, :dump_failures, :dump_summary

  def dump_summary(event)
    # The event is an RSpec::Core::Notifications::SummaryNotification
    # Let's mimic the BaseTextFormatter but without the failing test report
    output.puts 
    output.puts "Finished in #{event.formatted_duration}"
    output.puts "#{event.colorized_totals_line}"
  end

  def dump_failures(event)
    output.puts
    group = event.examples.each_with_object(Hash.new { |h, k| h[k] = [] }) do |e, m| 
      m[e.metadata[:full_description]] << e
      m
    end
    group.each { |description, examples| dump_example_summary(description, examples) }
  end

  def dump_example_summary(description, examples)
    output.puts description
    analysis = Flores::RSpec::Analyze::Analysis.new(group_by_result(examples))
    output.puts(analysis.to_s.gsub(/^/, "  "))
  end

  def group_by_result(examples) # rubocop:disable Metrics/AbcSize
    examples.each_with_object(Hash.new { |h, k| h[k] = [] }) do |example, results|
      status = example.metadata[:execution_result].status
      case status
      when :passed, :pending
        results[status] << [example.metadata[:values], nil]
      else
        exception = example.metadata[:execution_result].exception
        results[exception.class] << [example.metadata[:values], exception]
      end
      results
    end
  end

  def method_missing(m, *args)
    p m => args
  end
end
