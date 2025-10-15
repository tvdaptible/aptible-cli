require 'spec_helper'

describe Aptible::CLI::Agent do
  include Aptible::CLI::Helpers::DateHelpers

  let(:token) { double('Aptible::Auth::Token') }
  let(:generated_token) { double('Aptible::Auth::Token') }

  before do
    allow(subject).to receive(:ask)
    allow(subject).to receive(:save_token)
    allow(subject).to receive(:fetch_token) { token }
    allow(Aptible::Auth::Token).to receive(:create).and_return(generated_token)
    allow(generated_token).to receive(:token).and_return('eyJhbGciOiJSUzUxMiJ9.some-token')
  end

  describe '#token:create' do
    context 'when a token is created with valid auth' do
      it 'creates the token' do
        subject.send('token:create')
        expect(captured_output_text).not_to be_empty
        expect(captured_output_text).to start_with('eyJhbGciOiJSUzUxMiJ9.')
      end
    end
  end
end
