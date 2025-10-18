require 'socket'

require 'spec_helper'
require_relative './shared_activity_examples'

RSpec.describe Command::NetworkConnection do
  attributes = %i[destination_address source_address source_port destination_port protocol data_size]
  required_attributes = attributes - %i[source_address source_port]

  subject { described_class.new(timestamp:              123.4,
                                username:               'marc',
                                caller_process_cmdline: '/bin/rspec',
                                caller_process_name:    'rspec',
                                caller_process_pid:     456,
                                source_address:         '1.2.3.4',
                                source_port:            272,
                                destination_address:    '3.4.5.6',
                                destination_port:       321,
                                protocol:               'tcp',
                                data_size:              12) }


  it_behaves_like 'an activity command'

  describe 'attributes' do

    it 'should have the correct attributes' do
      expect(described_class.attribute_names).to include(*attributes.map(&:to_s))
    end

    describe 'address resolution' do

      it 'should accept an ipv4 destination address unchanged' do
        subject.destination_address = '34.215.227.142'

        expect(subject.destination_address).to eq('34.215.227.142')
      end

      it 'should accept an ipv6 destination address unchanged' do
        subject.destination_address = 'fd7a:115c:a1e0:ab12:4843:cd96:626f:e873'

        expect(subject.destination_address).to eq('fd7a:115c:a1e0:ab12:4843:cd96:626f:e873')
      end

      it 'should accept a valid destination hostname and resolve it' do
        subject.destination_address = 'zscaler.com'

        expect(subject.destination_address).not_to eq('zscaler.com')
        expect(subject).to be_valid_ip_address(subject.destination_address)
      end

      it 'should accept an ipv4 source address unchanged' do
        subject.source_address = '34.215.227.142'

        expect(subject.source_address).to eq('34.215.227.142')
      end

      it 'should accept an ipv6 source address unchanged' do
        subject.source_address = 'fd7a:115c:a1e0:ab12:4843:cd96:626f:e873'

        expect(subject.source_address).to eq('fd7a:115c:a1e0:ab12:4843:cd96:626f:e873')
      end

      it 'should accept a valid source hostname and resolve it' do
        subject.source_address = 'zscaler.com'

        expect(subject.source_address).not_to eq('zscaler.com')
        expect(subject).to be_valid_ip_address(subject.source_address)
      end

    end

    describe 'validation' do

      it 'should be valid' do
        expect(subject).to be_valid
      end

      required_attributes.each do |attribute_name|
        it "should require #{attribute_name} to be set" do
          subject.assign_attributes(attribute_name => nil)

          expect(subject).to be_invalid
          expect(subject.errors).to be_of_kind(attribute_name, :blank)
        end
      end

      it 'should not accept invalid protcols' do
        subject.protocol = 'pigeon'

        expect(subject).not_to be_valid
        expect(subject.errors).to be_of_kind(:protocol, :inclusion)
      end

      describe 'source address validation' do

        context 'for the tcp protocol' do
          before { subject.protocol = 'tcp' }

          it 'should be valid if both source address and source port are set' do
            subject.source_address = '2.2.2.2'
            subject.source_port    = 22

            expect(subject).to be_valid
          end

          it 'should be valid if only the source address is set' do
            subject.source_address = '2.2.2.2'
            subject.source_port    = nil

            expect(subject).to be_valid
          end

          it 'should be invalid if only the source port is set' do
            subject.source_address = nil
            subject.source_port    = 22

            expect(subject).not_to be_valid
            expect(subject.errors).to be_of_kind(:source_port, :present)
            expect(subject.errors.messages_for(:source_port).sole).to eq('source_port must be absent unless source_address is set')
          end

          it 'should be valid if both the source address and source port are nil' do
            subject.source_address = nil
            subject.source_port    = nil

            expect(subject).to be_valid
          end

        end

        context 'for the udp protocol' do
          before { subject.protocol = 'udp' }

          it 'should be valid if neither source address nor source port are set' do
            subject.source_address = nil
            subject.source_port    = nil

            expect(subject).to be_valid
          end

          it 'should be invalid if the source address is set' do
            subject.source_address = '2.2.2.2'
            subject.source_port    = nil

            expect(subject).not_to be_valid
            expect(subject.errors).to be_of_kind(:source_address, :present)
          end

          it 'should be invalid if the source address is set' do
            subject.source_address = '2.2.2.2'
            subject.source_port    = nil

            expect(subject).not_to be_valid
            expect(subject.errors).to be_of_kind(:source_address, :present)
          end

          it 'should be invalid if the source port is set' do
            subject.source_address = nil
            subject.source_port    = 22

            expect(subject).not_to be_valid
            expect(subject.errors).to be_of_kind(:source_port, :present)
          end

        end

      end

      describe 'data_size validation' do

        context 'for the tcp protocol' do
          before { subject.protocol = 'tcp' }

          it 'should be valid if the data_size is at least 0' do
            subject.data_size = 0
            expect(subject).to be_valid
          end

          it 'should be invalid if the data_size is less than 0' do
            subject.data_size = -1

            expect(subject).not_to be_valid
            expect(subject.errors).to be_of_kind(:data_size, :greater_than_or_equal_to)
          end

        end

        context 'for the udp protocol' do
          before { subject.assign_attributes(protocol: 'udp', source_address: nil, source_port: nil) }

          it 'should be valid if the data_size is greater than 0' do
            subject.data_size = 1
            expect(subject).to be_valid
          end

          it 'should be invalid if the data_size is less than 1' do
            subject.data_size = 0

            expect(subject).not_to be_valid
            expect(subject.errors).to be_of_kind(:data_size, :greater_than_or_equal_to)
          end

        end

      end
    end

  end

  describe 'command execution' do

    context 'tcp protocol' do

      def mock_tcp_socket(data_size)
        mock = instance_double('TCPSocket')

        allow(mock).to receive(:local_address)
                         .and_return(Addrinfo.tcp('9.8.7.6', 54))

        if data_size && data_size > 0
          valid_message = satisfy { |s|
            s.is_a?(String) &&
              s.length == data_size
          }
          expect(mock).to receive(:send)
                            .with(valid_message, 0)

        else
          expect(mock).not_to receive(:send)
        end

        expect(mock).to receive(:closed?)
        expect(mock).to receive(:close)

        mock
      end

      it 'should send network data' do
        mock_socket = mock_tcp_socket(12)
        expect(TCPSocket).to receive(:open)
                               .with('3.4.5.6', 321, '1.2.3.4', 272)
                               .and_return(mock_socket)

        subject.execute!
      end

      it 'should not send network data if the data_size is 0' do
        subject.data_size = 0
        mock_socket = mock_tcp_socket(0)
        expect(TCPSocket).to receive(:open)
                               .with('3.4.5.6', 321, '1.2.3.4', 272)
                               .and_return(mock_socket)

        subject.execute!
      end

      it 'should set the source address and port if they are not provided' do
        subject.source_address = nil
        subject.source_port    = nil

        mock_socket = mock_tcp_socket(12)
        expect(TCPSocket).to receive(:open)
                               .with('3.4.5.6', 321, nil, nil)
                               .and_return(mock_socket)

        subject.execute!

        expect(subject.source_address).to eq('9.8.7.6')
        expect(subject.source_port).to eq(54)
      end

      it 'should not set the source address and port if they are already provided' do
        mock_socket = mock_tcp_socket(12)
        expect(TCPSocket).to receive(:open)
                               .with('3.4.5.6', 321, '1.2.3.4', 272)
                               .and_return(mock_socket)

        subject.execute!

        expect(subject.source_address).to eq('1.2.3.4')
        expect(subject.source_port).to eq(272)
      end

    end

    context 'udp protocol' do

      before do
        subject.assign_attributes(protocol:       'udp',
                                  source_address: nil,
                                  source_port:    nil)
      end

      def mock_udp_socket(data_size)
        mock = instance_double('UDPSocket')
        expect(mock).to receive(:connect)
                          .with(subject.destination_address, subject.destination_port)

        allow(mock).to receive(:local_address)
                         .and_return(Addrinfo.udp('9.8.7.6', 54))

        valid_message = satisfy { |s|
          s.is_a?(String) &&
            s.length == data_size
        }
        expect(mock).to receive(:send)
                          .with(valid_message, 0)

        expect(mock).to receive(:closed?)
        expect(mock).to receive(:close)

        mock
      end

      it 'should send network data' do
        mock_socket = mock_udp_socket(12)
        expect(UDPSocket).to receive(:new)
                               .and_return(mock_socket)

        subject.execute!
      end

      it 'should set the source address and port' do
        mock_socket = mock_udp_socket(12)
        expect(UDPSocket).to receive(:new)
                               .and_return(mock_socket)

        subject.execute!

        expect(subject.source_address).to eq('9.8.7.6')
        expect(subject.source_port).to eq(54)
      end

    end
  end

  it 'should generate the correct log info' do
    expect(subject.activity_log_entry).to eq(activity_type:        :network_connect,
                                             timestamp:              123.4,
                                             username:               'marc',
                                             caller_process_cmdline: '/bin/rspec',
                                             caller_process_name:    'rspec',
                                             caller_process_pid:     456,
                                             source_address:         '1.2.3.4',
                                             source_port:            272,
                                             destination_address:    '3.4.5.6',
                                             destination_port:       321,
                                             protocol:               'tcp',
                                             data_size:              12)
  end

end
