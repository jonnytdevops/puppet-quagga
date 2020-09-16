# ex: syntax=puppet si sw=4 ts=4 et

define quagga::daemon (
    $enable,
    $hostname,
    $vty_password,
    $vty_enable_password,
) {
    $value = $enable ? {
        true    => 'yes',
        false   => 'no',
        default => $enable,
    }
    augeas { "quagga-daemon-${name}":
        changes => "set /files/etc/quagga/daemons/${name} '${value}'",
        lens    => 'Shellvars.lns',
        incl    => '/etc/quagga/daemons',
        require => Package['quagga'],
        notify  => Service['quagga'],
    }

    if $value == 'no' {
        file { "/etc/quagga/${name}.conf":
            ensure => absent,
        }
    } else {
        concat { "/etc/quagga/${name}.conf":
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            require => Package['quagga'],
            notify  => Service['quagga'],
        }

        concat::fragment { "${name}.conf-common":
            target  => "/etc/quagga/${name}.conf",
            order   => '00',
            content => template('quagga/common.erb'),
        }
    }
}
