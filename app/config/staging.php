<?php
$parameters = array (
    'db_driver' => 'pdo_mysql',
    'db_port' => '3306',
    'db_host' => getenv('MAUTIC_DB_HOST'),
    'db_name' => getenv('MAUTIC_DB_NAME'),
    'db_user' => getenv('MAUTIC_DB_USER'),
    'db_password' => getenv('MAUTIC_DB_PASSWORD'),
);
