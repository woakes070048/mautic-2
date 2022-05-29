<?php

/**
 * Copied from https://github.com/mautic/mautic/blob/4.x/index.php with the following line
 * added.
 *
 * @link https://forum.mautic.org/t/mautic-redirect-loop/16990/3
 */
$_SERVER['HTTPS'] = 'on';

/*
 * @copyright   2014 Mautic Contributors. All rights reserved
 * @author      Mautic
 *
 * @link        http://mautic.org
 *
 * @license     GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 */
define('MAUTIC_ROOT_DIR', __DIR__);

// Fix for hosts that do not have date.timezone set, it will be reset based on users settings
date_default_timezone_set('UTC');

require_once 'autoload.php';

use Mautic\CoreBundle\ErrorHandler\ErrorHandler;
use Mautic\Middleware\MiddlewareBuilder;
use function Stack\run;

ErrorHandler::register('prod');

run((new MiddlewareBuilder(new AppKernel('prod', false)))->resolve());
