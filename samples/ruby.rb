module Ergolight
  VERSION = "1.0.0"

  class Order
    attr_reader :id, :status

    def initialize(id:, status: :draft)
      @id = id
      @status = status
    end

    def paid?
      status == :paid
    end
  end

  orders = [Order.new(id: 1, status: :paid)]
  orders.each { |order| puts "#{VERSION}: #{order.id} #{order.paid?}" }
end

