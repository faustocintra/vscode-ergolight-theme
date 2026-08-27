class Order
  constructor: (@id, @status = 'draft') ->

  render: ->
    "#{@id}:#{@status}"

orders = [
  new Order 1, 'paid'
  new Order 2
]

for order, index in orders when order.status isnt 'cancelled'
  console.log index, order.render()

module.exports = { Order, orders }

