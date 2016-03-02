require 'spec_helper'
describe 'editors' do

  context 'with defaults for all parameters' do
    it { should contain_class('editors') }
  end
end
