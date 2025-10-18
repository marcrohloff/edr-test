require 'ipaddr'
require 'resolv'
require 'socket'

module Command
  class NetworkConnection < Base
    include ActivityConcern

    attribute :source_address,      :string
    attribute :source_port,         :integer
    attribute :destination_address, :string
    attribute :destination_port,    :integer
    attribute :protocol,            :string
    attribute :data_size,           :integer

    validates :destination_address, :destination_port,
              :protocol, :data_size,
              presence: true

    # source_port can only be provided if source_address is provided
    validates :source_address, :source_port,
              absence: { if: -> { protocol == 'udp' },
                         message: 'source_address and source_port cannot be configured for udp' }
    validates :source_port,
              absence: { unless: :source_address,
                         message: 'source_port must be absent unless source_address is set' }

    validates :protocol, inclusion: { in: %w[tcp udp] }

    # tcp can connect without sending data but udp is connectionless so data is required
    validates :data_size, numericality: { greater_than_or_equal_to: 1, if: -> { protocol == 'udp' } }
    validates :data_size, numericality: { greater_than_or_equal_to: 0, if: -> { protocol != 'udp' } }

    def self.activity_type = :network_connect

    def destination_address=(address)
      super(normalize_address(address))
    end

    def source_address=(address)
      super(normalize_address(address))
    end

    def execute!
      with_socket do |socket|
        set_source_addresses(socket)

        if data_size && data_size > 0
          message = '0' * data_size
          socket.send(message, 0)
        end
      end
    end

    def valid_ip_address?(address)
      return false unless address.present?

      IPAddr.new(address)
      true

    rescue IPAddr::InvalidAddressError
      false
    end

    private

    def normalize_address(address)
      if address.blank?
        nil
      elsif valid_ip_address?(address)
        address
      else
        resolve_address(address)
      end
    end

    def resolve_address(address)
      address && Resolv.getaddress(address)
    end

    def open_socket
      case protocol
      when 'tcp'
        TCPSocket.open(destination_address, destination_port, source_address, source_port)

      when 'udp'
        UDPSocket.new.tap do |socket|
          socket.connect(destination_address, destination_port)
        end

      else
        raise ArgumentError, "Unsupported protocol: #{protocol}"

      end
    end

    def with_socket(&block)
      socket = open_socket
      yield socket

    ensure
      socket.close if socket && !socket.closed?
    end

    def set_source_addresses(socket)
      return if source_address.present? && source_port.present?

      local  = socket.local_address
      self.source_address ||= local.ip_address&.encode(Encoding::UTF_8).presence
      self.source_port    ||= local.ip_port
    end

  end
end
