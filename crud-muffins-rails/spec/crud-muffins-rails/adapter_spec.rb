require 'spec_helper'

describe CrudMuffins::Rails::Adapter do
  let(:model) { FakeApplicationAdapterModel.new }
  let(:adapter) { CrudMuffins::Rails::Adapter.new(model) }

  describe '#save' do
    it 'should delegate' do
      expect(adapter.save).to eq 'save test'
    end
  end

  describe '#update' do
    it 'should update model with deserialized params' do
      model_dbl = double
      expect(model_dbl).to receive(:update).with(foo_bar: 42)
      allow(adapter).to receive(:deserialize).and_return foo_bar: 42
      allow(adapter).to receive(:model).and_return(model_dbl)
      adapter.update(fooBar: 42)
    end
  end

  describe '#errors' do
    it 'should work' do
      adapter.valid?
      expect(adapter.errors).to eq({ errors: ["Foo bar can't be blank"],
                                     modelErrors: { 'fooBar' => ["can't be blank"] } })
    end
  end
end
