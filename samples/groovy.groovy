package ergolight.sample

import groovy.transform.Immutable

@Immutable
class Order {
    Long id
    String status = 'draft'

    String render() {
        "${id}:${status?.toUpperCase()}"
    }
}

trait Auditable {
    abstract String render()
}

def orders = [new Order(1L, 'paid'), new Order(2L)]
orders.eachWithIndex { order, index ->
    println "${index} -> ${order.render()}"
}

