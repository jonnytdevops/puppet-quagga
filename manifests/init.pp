# ex: syntax=puppet ts=4 sw=4 si et
class quagga (
    $hostname            = undef,
    $vty_password        = undef,
    $vty_enable_password = undef,
    $router_id           = undef,
    $interfaces          = undef,
    $networks            = undef,
    $redistribute        = undef,
    $ospf_areas          = undef,
    $zebra               = undef,
    $bgpd                = undef,
    $ospfd               = undef,
    $ospf_area           = undef,
    $ospf6d              = undef,
    $ospf_ref_bw         = undef,
    $ripd                = undef,
    $ripngd              = undef,
    $isisd               = undef,
    $babeld              = undef,
    $package_name        = undef,
    $service_name        = undef,
    $service_hasstatus   = undef,
    $service_status      = undef,
) {
    File {
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['quagga'],
        notify  => Service['quagga'],
    }

    Quagga::Daemon {
        hostname            => $hostname,
        vty_password        => $vty_password,
        vty_enable_password => $vty_enable_password,
    }

    package { 'quagga':
        ensure => latest,
        name   => $package_name,
    }

    file { '/etc/quagga/vtysh.conf':
        content => template('quagga/vtysh.conf.erb'),
    }

    quagga::daemon { 'zebra': enable => $zebra, }

    if $zebra {
        concat::fragment { 'zebra.conf-main':
            target  => '/etc/quagga/zebra.conf',
            order   => '10',
            content => template('quagga/zebra.erb'),
        }
    }

    quagga::daemon { 'bgpd': enable => $bgpd, }

    quagga::daemon { 'ospfd': enable => $ospfd, }

    if $ospfd {
        concat::fragment { 'ospfd.conf-main':
            target  => '/etc/quagga/ospfd.conf',
            order   => '10',
            content => template('quagga/ospfd.erb'),
        }
    }

    quagga::daemon { 'ospf6d': enable => $ospf6d, }

    quagga::daemon { 'ripd': enable => $ripd, }

    quagga::daemon { 'ripngd': enable => $ripngd, }

    quagga::daemon { 'isisd': enable => $isisd, }

    quagga::daemon { 'babeld': enable => $babeld, }

    service { 'quagga':
        ensure    => running,
        name      => $service_name,
        hasstatus => $service_hasstatus,
        status    => $service_status,
    }
}
