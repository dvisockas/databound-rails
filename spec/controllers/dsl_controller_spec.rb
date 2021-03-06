require 'spec_helper'

describe DslController, type: :controller do
  describe '#create' do
    describe 'strict' do
      describe 'without data usage' do
        before :each do
          data = {
            data: {
              name: 'John',
              city: 'hottest',
            },
            scope: {},
          }

          post(:create, javascriptize(data))
        end

        it 'responds consistently to js' do
          expect(rubize(response)).to eq(
            success: true,
            id: '1',
            scoped_records: all_records,
          )
        end

        it 'creates the record' do
          user = User.find(1)
          user_attributes = user.attributes.to_options

          expect(user_attributes.slice(:id, :name, :city)).to eq(
            id: 1,
            name: 'John',
            city: 'Miami',
          )
        end
      end

      describe 'with data usage' do
        before :each do
          data = {
            data: {
              name: 'John',
              city: 'coldest',
            },
            scope: {},
          }

          post(:create, javascriptize(data))
        end

        it 'responds consistently to js' do
          expect(rubize(response)).to eq(
            success: true,
            id: '1',
            scoped_records: all_records,
          )
        end

        it 'creates the record' do
          user = User.find(1)
          user_attributes = user.attributes.to_options

          expect(user_attributes.slice(:id, :name, :city)).to eq(
            id: 1,
            name: 'John',
            city: 'Where John lives',
          )
        end
      end
    end

    describe 'loose' do
      it 'responds with error' do
        data = {
          data: {
            name: 'John',
            city: 'New York',
          },
          scope: {},
        }

        assert_responses(
          -> { post(:create, javascriptize(data)) },
          Databound::NotPermittedError,
          "DSL column 'city' received unmatched string 'New York'." \
          " Use 'strict: false' in DSL definition to allow everything.",
        )
      end
    end
  end

  describe '#update' do
    describe 'strict' do
      describe 'without data usage' do
        before :each do
          User.create(name: 'John', city: 'New York')

          data = {
            data: {
              id: 1,
              city: 'hottest',
            },
            scope: {},
          }

          post(:update, javascriptize(data))
        end

        it 'responds consistently to js' do
          expect(rubize(response)).to eq(
            success: true,
            id: '1',
            scoped_records: all_records,
          )
        end

        it 'updates the record' do
          user = User.find(1)
          user_attributes = user.attributes.to_options

          expect(user_attributes.slice(:id, :name, :city)).to eq(
            id: 1,
            name: 'John',
            city: 'Miami',
          )
        end
      end

      describe 'with data usage' do
        before :each do
          User.create(name: 'John', city: 'New York')

          data = {
            data: {
              id: 1,
              name: 'Peter',
              city: 'coldest',
            },
            scope: {},
          }

          post(:update, javascriptize(data))
        end

        it 'responds consistently to js' do
          expect(rubize(response)).to eq(
            success: true,
            id: '1',
            scoped_records: all_records,
          )
        end

        it 'updates the record' do
          user = User.find(1)
          user_attributes = user.attributes.to_options

          expect(user_attributes.slice(:id, :name, :city)).to eq(
            id: 1,
            name: 'Peter',
            city: 'Where Peter lives',
          )
        end
      end
    end

    describe 'loose' do
      it 'responds with error' do
        User.create(name: 'John', city: 'Los Angeles')

        data = {
          data: {
            id: 1,
            name: 'John',
            city: 'New York',
          },
          scope: {},
        }

        assert_responses(
          -> { post(:create, javascriptize(data)) },
          Databound::NotPermittedError,
          "DSL column 'city' received unmatched string 'New York'." \
          " Use 'strict: false' in DSL definition to allow everything.",
        )
      end
    end
  end
end
