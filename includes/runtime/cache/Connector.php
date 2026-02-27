<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/

include_once dirname(__FILE__) . '/MemoryConnector.php';

class Vtiger_Cache_Connector {
	protected static $instance = false;

	public static function getInstance() {
		if (self::$instance) return self::$instance;
		self::$instance = new Vtiger_Cache_MemoryConnector();
		return self::$instance;
	}
}
