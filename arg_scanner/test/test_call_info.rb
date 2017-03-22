#!/usr/bin/env ruby
require File.expand_path("helper", File.dirname(__FILE__))

include ArgScanner

class TestCallInfoWrapper

  def sqr(z1 = 10, z2 = 11, z3 = 13, z4 = 14, z5, z6, z7, z8, y: '0', x: "40")

  end

  def sqr2(z0, z1 = 2, z2 = 10, z3 = 2, z4 = 0, y: 1, x: 30, z: 40)

  end

  def foo(a, b, c, *d, e)

  end

  def foo2(*args)

  end

  def foo3(b: 2, c: 3, **args)

  end

  def foo3(b: 2, c:, **args)

  end

  def foo4(b: 2, c:, d: "1", dd: 1, ddd: '111', **args)

  end

  attr_accessor :call_info
  attr_accessor :trace

  def handle_call(tp)
    ArgScanner.get_call_info
  end

  def initialize
    @trace = TracePoint.trace(:call) do |tp|
      case tp.event
        when :call
          @call_info = handle_call(tp)
      end
    end
  end

end

class TestCallInfo < Test::Unit::TestCase
  def setup
    @call_info_wrapper = TestCallInfoWrapper.new
  end

  def teardown

  end

  def test_simple
    @call_info_wrapper.sqr2(10, 11)
    @call_info_wrapper.trace.disable

    assert @call_info_wrapper.call_info.size == 2
    assert @call_info_wrapper.call_info[0] == "sqr2"
    assert @call_info_wrapper.call_info[1] == 2
  end

  def test_simple_kw
    @call_info_wrapper.sqr2(10, 11, x: 10, y: 1)
    @call_info_wrapper.trace.disable

    assert @call_info_wrapper.call_info.size == 3
    assert @call_info_wrapper.call_info[0] == "sqr2"
    assert @call_info_wrapper.call_info[1] == 4
    assert @call_info_wrapper.call_info[2].join(',') == "x,y"
  end

  def test_rest
    @call_info_wrapper.foo2(1, 2, 3, 4, 5, 6, 7, 8)
    @call_info_wrapper.trace.disable

    assert @call_info_wrapper.call_info.size == 2
    assert @call_info_wrapper.call_info[0] == "foo2"
    assert @call_info_wrapper.call_info[1] == 8
  end

  def test_post_and_rest
    @call_info_wrapper.foo(1, 2, 3, 4, 5, 6, 7, 8)
    @call_info_wrapper.trace.disable

    assert @call_info_wrapper.call_info.size == 2
    assert @call_info_wrapper.call_info[0] == "foo"
    assert @call_info_wrapper.call_info[1] == 8
  end

  def test_kwrest
    @call_info_wrapper.foo3(a: 1, b: 2, c: 3, d: 4)
    @call_info_wrapper.trace.disable

    assert @call_info_wrapper.call_info.size == 3
    assert @call_info_wrapper.call_info[0] == "foo3"
    assert @call_info_wrapper.call_info[1] == 4
    assert @call_info_wrapper.call_info[2].join(',') == "a,b,c,d"
  end

  def test_rest_and_reqkw_args
    @call_info_wrapper.foo4(b: "hello", c: 'world', e: 1, f: "not")
    @call_info_wrapper.trace.disable

    assert @call_info_wrapper.call_info.size == 3
    assert @call_info_wrapper.call_info[0] == "foo4"
    assert @call_info_wrapper.call_info[1] == 4
    assert @call_info_wrapper.call_info[2].join(',') == "b,c,e,f"

  end
end