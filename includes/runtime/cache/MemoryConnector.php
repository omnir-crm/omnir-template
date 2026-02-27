<?php
/*+***********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *************************************************************************************/

class Vtiger_Cache_MemoryConnector {
	private $cache = array();

	public static function getInstance() {
		static $instance = false;
		if ($instance) return $instance;
		$instance = new self();
		return $instance;
	}

	public function get($ns, $key) {
		$key = $this->prepareKey($key);
		if (isset($this->cache[$ns][$key])) {
			return $this->cache[$ns][$key];
		}
		return false;
	}

	public function set($ns, $key, $value) {
		$key = $this->prepareKey($key);
		$this->cache[$ns][$key] = $value;
	}

	public function delete($ns, $key) {
		$key = $this->prepareKey($key);
		unset($this->cache[$ns][$key]);
	}

	private function prepareKey($key) {
		if (is_scalar($key)) return $key;
		return md5(serialize($key));
	}

	public function flush() {
		$this->cache = array();
	}
}
