# ex: syntax=puppet si sw=4 ts=4 et
define quagga::access_list (
    $networks = [],
    $action   = 'permit',
    $service,
) {
    concat::fragment { "quagga-access-list-${name}":
        target  => "/etc/quagga/${service}.conf",
        order   => "20",
        content => template('quagga/access_list.erb'),
    }
}
