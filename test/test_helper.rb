require 'minitest/autorun'
require 'active_support'
require 'active_support/cache'
require 'active_support/cache/memory_store'
require 'active_support/core_ext/module/deprecation'
require 'rails'
require 'action_controller/railtie'
require 'mocha/mini_test'

require 'cacheable'

Cacheable.logger = Class.new { def info(a); end }.new

class MockController < ActionController::Base
  def self.after_filter(*args); end

  def headers; response.headers; end

  def params
    @params ||= {fill_cache: false}
  end

  def request
    @request ||= Class.new do
      def url; "http://example.com/"; end
      def get?; true; end
      def env; @env ||= {'REQUEST_URI' => '/'}; end
      def params; {}; end
    end.new
  end

  def response
    @response ||= Class.new do
      attr_accessor :body
      def headers; @headers ||= { 'Status' => 200, 'Content-Type' => 'text/html' }; end
    end.new
  end

  def logger
    Cacheable.logger
  end

  include Cacheable::Controller

  def cacheable?; true; end
end

$: << File.expand_path('../lib', __FILE__)
require 'cacheable'

