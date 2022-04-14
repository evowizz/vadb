// Copyright 2022 Dylan Roussel
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module adb

import os
import cache
import sdk
import regex
import utils

pub fn kill_server() {
	execute('kill-server')
}

pub fn list_devices() []string {
	ensure_server()

	res := execute('devices').trim_space().split_into_lines()

	// Create regex to separate device name from status
	mut reg := regex.regex_opt('\\s') or { panic(@MOD + '.' + @FN + ': Cannot create regex') }

	mut devices := []string{}
	// Ignoring first line which is just a header
	for line in res[1..] {
		if line.contains('offline') {
			continue
		}

		start, _ := reg.find(line)
		serial := line[..start]
		devices << serial
	}

	return devices
}

pub fn get_unique_device() ?AndroidDevice {
	devices := list_devices()

	if devices.len != 1 {
		return no_unique_device_error()
	}

	return AndroidDevice{devices[0]}
}

pub fn get_usb_device() ?AndroidDevice {
	return get_device_by_type('-d')
}

pub fn get_emulator_device() ?AndroidDevice {
	return get_device_by_type('-e')
}

fn get_device_by_type(flag string) ?AndroidDevice {
	ensure_server()

	res := execute(flag + ' get-serialno').trim_space()
	if res == 'unknown' {
		return no_unique_device_error()
	}

	return get_device_by_serial(res)
}

fn get_device_by_serial(serial string) ?AndroidDevice {
	for device in list_devices() {
		if device == serial {
			return AndroidDevice{device}
		}
	}

	return device_not_found_error()
}

fn ensure_server() {
	execute('start-server')
}

fn execute(command string) string {
	res := run(command)
	if res.exit_code != 0 {
		eprintln('adb $command failed with return code $res.exit_code')
		eprintln(res.output)
		exit(1)
	}

	return res.output
}

fn run(command string) os.Result {
	adb_path := get_adb() or { return os.Result{2, err.msg()} }

	return utils.run(adb_path + ' ' + command)
}

fn get_adb() ?string {
	mut adb_path := cache.get_string(@MOD + '.' + @FN)

	if adb_path != '' {
		return adb_path
	}

	adb_path = sdk.adb_path()

	if adb_path == '' || !os.exists(adb_path) {
		return error('adb not found')
	}

	if !os.is_executable(adb_path) {
		return error('adb is not executable')
	}

	cache.set_string(@MOD + '.' + @FN, adb_path)

	return adb_path
}
