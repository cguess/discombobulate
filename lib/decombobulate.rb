# frozen_string_literal: true

require_relative "decombobulate/version"
require "JSON"
require "CSV"
require "debug"

class Decombobulate
  class Error < StandardError; end

  attr_reader :headers, :rows

  def initialize(json)
    # Parse the JSON if we need to
    json = Json.parse(json) if json.is_a?(String)
    if json.is_a?(Array)
      @headers = parse_headers_from_json(json.first)
      @rows = json.map do |json_row|
        parse_json_object_into_row(json_row)
      end
    else
      @headers = parse_headers_from_json(json)
      @rows = [parse_json_object_into_row(json)]
    end
  end

  def to_csv
    CSV.generate do |csv|
      csv << @headers
      @rows.each do |row|
        csv << row
      end
    end
  end

  def parse_headers_from_json(json, parent_key = nil)
    @headers ||= []
    json.keys.each do |key|
      flattened_key = parent_key.nil? ? key.to_s : "#{parent_key}.#{key}"

      unless json[key].is_a?(Hash)
        @headers << flattened_key
      else
        parse_headers_from_json(json[key], flattened_key)
      end
    end

    @headers
  end

  def parse_json_object_into_row(json)
    @headers.map do |header|
      header_array = header.split(".").map(&:to_sym)
      value = json.dig(*header_array)
      value = value.join(", ") if value.is_a?(Array)

      value
    end
  end
end
