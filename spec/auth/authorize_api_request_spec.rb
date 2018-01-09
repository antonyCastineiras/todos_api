require 'rails_helper'

RSpec.describe AuthorizeApiRequest do
	# create test user
	let(:user) { create(:user) }
	# Mock authorization header
	let(:header) { { 'Authorization' => token_generator(user.id) } }
	# Invalid request subject
	subject(:invalid_request_obj) { described_class.new({}) }
	# Valid request subject
	subject(:request_obj) { described_class.new(header) }

	describe '#call' do
		# returns user object whn the request is valid
		context 'when valid request' do
			it 'returns a user object' do
				result = request_obj.call
				expect(result[:user]).to eq(user)
			end
		end

		context 'when invalid request' do
			context 'when missing token' do
				it 'raises a missing token error' do
					expect { invalid_request_obj.call }.to raise_error(ExceptionHandler::MissingToken, 'Missing token')
				end
			end

			context 'when invalid token' do
				subject(:invalid_request_obj) do
					described_class.new('Authorization' => token_generator(5))
				end

				it 'raises an invalid token error' do
					expect { invalid_request_obj.call }.to raise_error(ExceptionHandler::InvalidToken, /Invalid token/)
				end
			end

			context 'when token is expired' do
				let(:header) { { 'Authorization' => expired_token_generator(user.id) } }
				subject(:request_obj) { described_class.new(header) }

				it 'raises ExceptionHandler::ExpiredSignature error' do
					expect { request_obj.call }.to raise_error(ExceptionHandler::InvalidToken, /Signature has expired/)
				end
			end
		end
	end
end