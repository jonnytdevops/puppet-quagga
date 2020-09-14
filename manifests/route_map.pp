# ex: syntax=puppet si sw=4 ts=4 et
define quagga::route_map (
    $service,
    $entries = {},
) {
    concat::fragment { "quagga-route-map-${name}":
        target  => "/etc/quagga/${service}.conf",
        order   => '30',
        content => template('quagga/route_map.erb'),
    }
}
