# frozen_string_literal: true

require_relative "decombobulate/version"
require "json"
require "csv"

class Decombobulate
  class Error < StandardError; end

  attr_reader :headers, :rows

  def initialize(json)
    # Parse the JSON if we need to
    json = Json.parse(json) if json.is_a?(String)


    # Yes, I tried a case/when statement but for some reason that doesn't work when looking at class types
    if json.is_a?(Array)
      @headers = parse_headers_from_json(json.first)
      @rows = json.map do |json_row|
        collapse_json_object_row_to_csv_row(json_row)
      end
    elsif json.is_a?(Hash)
      @headers = parse_headers_from_json(json)
      @rows = [collapse_json_object_row_to_csv_row(json)]
    else
      raise "JSON object must have an array or object as the top level object."
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

  def parse_headers_from_json(json, parent_key = nil)
    @headers ||= []

    if json.is_a?(Hash)
      json.keys.each do |key|
        flattened_key = parent_key.nil? ? key.to_s : "#{parent_key}.#{key}"

        if json[key].is_a?(Hash) || json[key].is_a?(Array)
          parse_headers_from_json(json[key], flattened_key)
        else
          @headers << flattened_key
        end
      end
    elsif json.is_a?(Array)
      json.each do |j_object|
        parse_headers_from_json(j_object, parent_key)
      end
    else
      # This mean's we either have a parsing error or we're in an array.
      # I'm assuming the JSON coming in is valid, so we're going to just skip this
      return nil
    end

    @headers
  end

  def collapse_json_object_row_to_csv_row(json)
    # Time to do a graph traversal! And recursively! Java 103 is usefuL!!!!
    row_array = []

    if json.is_a?(Array)
      json.each do |j_object|
        if j_object.is_a?(Array) || j_object.is_a?(Hash)
          row_array << collapse_json_object_row_to_csv_row(j_object)
        else
          row_array << j_object
        end
      end
    elsif json.is_a?(Hash)
      json.keys.each do |key|
        if json[key].is_a?(Array) || json[key].is_a?(Hash)
          row_array << collapse_json_object_row_to_csv_row(json[key])
        else
          row_array << json[key]
        end
      end
    end

    row_array.flatten
  end
end
