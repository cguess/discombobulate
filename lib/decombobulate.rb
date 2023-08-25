# frozen_string_literal: true

require_relative "decombobulate/version"
require "json"
require "csv"

class Decombobulate
  class Error < StandardError; end

  attr_reader :rows, :headers

  def initialize(json)
    # Parse the JSON if we need to
    json = Json.parse(json) if json.is_a?(String)

    # Yes, I tried a case/when statement but for some reason that doesn't work when looking at class types
    columns = json_to_csv(json)

    @rows = []
    if columns.is_a?(Array)
      merged_columns = {}

      # Iterate through the array, finding each key, adding it to the headers row if it's not there already
      # then merge them

      columns.each do |entry|
        entry.keys.each do |key|
          merged_columns[key] = [] unless merged_columns.has_key?(key)
          merged_columns[key] << entry[key]
          merged_columns[key] = merged_columns[key].flatten
        end
      end
      columns = merged_columns
    end
    # 6.) Now we have a hash of @columns, we need to turn it into rows
    #     We're going to assume that all the @columns are the same length
    #     So we'll just iterate over the first column and add the values to the row
    @headers = columns.keys.map(&:to_s)
    columns[columns.keys.first].size.times do |index|
      @rows << columns.keys.map { |key| columns[key][index] }
    end
  end

  def to_csv(file_name = nil)
    if file_name.nil?
      csv_final = CSV.generate(encoding: "UTF-8") do |csv|
        csv << @headers
        @rows.each do |row|
          csv << row
        end
      end
    else
      CSV.open(file_name, "wb", encoding: "UTF-8") do |csv|
        csv << @headers
        @rows.each do |row|
          csv << row
        end
      end

      return true
    end

    csv_final
  end

private

  def json_to_csv(json = {}, nested_name = nil, depth: 0)
    @columns ||= {}
    unless json.is_a?(Hash) || json.is_a?(Array)
      @columns[nested_name] = [] unless @columns.has_key?(nested_name)
      @columns[nested_name] << json
      return @columns
    end

    if json.is_a?(Array)
      json.each do |j|
        json_to_csv(j, depth: depth + 1)
      end
      return @columns
      # return @columns
    end
    # OK, so we need arbitrarily long fields so we're doing a different algorithm I literally came up
    # with in five minutes one morning before falling back asleep, let's see if it works.
    #
    # Basically we're going to represent the @columns separately, and hope the row line up correctly
    # This allows us to add new @columns and fill up the empty fields as needed
    #
    # 1. Make a hash of arrays
    #    This is already done in the function call

    # 2.) Add all the keys in the JSON at the level to the hash
    json.keys.each do |key|
      column_name = nested_name.nil? ? key : "#{nested_name}.#{key}".to_sym
      @columns[column_name] = [] unless @columns.has_key?(column_name)
    end

    # 3.) Go through each key, if it's a bare value just add it in
    json.keys.each do |key|
      value = json[key]
      # 4.) If it's an array, start adding @columns in the format "key_1" "key_2" for the length of the array
      if value.is_a?(Array)
        column_name = nested_name.nil? ? key : "#{nested_name}.#{key}".to_sym
        # We want to get rid of the key if it's an array, since we're going to be adding @columns
        @columns.delete(column_name)

        # Now add the values to the @columns
        value.each_with_index do |array_value, index|
          column_name = nested_name.nil? ? "#{key}.#{index + 1}".to_sym : "#{nested_name}.#{key}.#{index + 1}".to_sym
          json_to_csv(array_value, column_name, depth: depth + 1)
        end
      elsif value.is_a?(Hash)
        # 5.) If it's a hash, recursively call this function and add the @columns to the hash
        column_name = nested_name.nil? ? key : "#{nested_name}.#{key}".to_sym
        @columns.delete(column_name)
        json_to_csv(value, column_name, depth: depth + 1)
      else
        column_name = nested_name.nil? ? key : "#{nested_name}.#{key}".to_sym
        @columns[column_name] = [] unless @columns.has_key?(column_name)

        # Fill the column with nils up to the current length of the other @columns
        # get the longest column size
        longest_column_size = @columns.values.map(&:size).max

        while @columns[column_name].size < longest_column_size - 1
          @columns[column_name] << nil
        end if longest_column_size > 1

        @columns[column_name] << value
      end
    end

    @columns
  end
end
