# frozen_string_literal: true

require "test_helper"
require "json"

class TestDecombobulate < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Decombobulate::VERSION
  end

  def test_a_flat_structure_headers
    object = {
      a: "test",
      b: "test"
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal ["a", "b"], decombobulate_object.headers
  end

  def test_a_one_level_nested_structure_headers
    object = {
      a: "test",
      b: {
        c: "test",
        d: "here",
      },
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal ["a", "b.c", "b.d"], decombobulate_object.headers
  end

  def test_a_two_level_nested_structure_headers
    object = {
      a: "test",
      b: {
        c: "test",
        d: "here",
        e: {
          f: "test again",
          g: "testing 1 2 3",
        }
      },
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal ["a", "b.c", "b.d", "b.e.f", "b.e.g"], decombobulate_object.headers
  end

  def test_a_flat_structure_row
    object = {
      a: "test_1",
      b: "test_2"
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal ["test_1", "test_2"], decombobulate_object.parse_json_object_into_row(object)
  end

  def test_a_one_level_nested_structure_row
    object = {
      a: "test_1",
      b: {
        c: "test_2",
        d: "test_3",
      },
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal ["test_1", "test_2", "test_3"], decombobulate_object.parse_json_object_into_row(object)
  end

  def test_a_two_level_nested_structure_row
    object = {
      a: "test_1",
      b: {
        c: "test_2",
        d: "test_3",
        e: {
          f: "test_4",
          g: "test_5",
        }
      },
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal ["test_1", "test_2", "test_3", "test_4", "test_5"], decombobulate_object.parse_json_object_into_row(object)
  end

  def test_an_array_is_converted_to_a_string
    object = {
      a: "test_1",
      b: ["test_2", "test_3", "test_4"]
    }

    decombobulate_object = Decombobulate.new(object)
    assert_equal [["test_1", "test_2, test_3, test_4"]], decombobulate_object.rows
  end

  def test_an_array_of_top_level_objects_works
    object = [{
      a: "test_1",
      b: ["test_2", "test_3", "test_4"]
    }]

    decombobulate_object = Decombobulate.new(object)
    assert_equal [["test_1", "test_2, test_3, test_4"]], decombobulate_object.rows
  end

  def test_can_generate_csv
    object = {
      a: "test_1",
      b: {
        c: "test_2",
        d: "test_3",
        e: {
          f: "test_4",
          g: "test_5",
        }
      },
    }

    assert_equal Decombobulate.new(object).to_csv, "a,b.c,b.d,b.e.f,b.e.g\ntest_1,test_2,test_3,test_4,test_5\n"
  end
end
