require "bundler/setup"
require "crud-muffins-rails"
require 'active_model'
require 'active_support'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class FakeModel
  include ActiveModel::Validations
  include ActiveModel::Model
end

class FakeApplicationAdapterModel < FakeModel
  attr_accessor :foo_bar
  validates :foo_bar, presence: true

  def save
    'save test'
  end
end
