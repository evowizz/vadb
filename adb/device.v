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

struct AndroidDevice {
pub:
	serial string [required]
}

pub fn (device AndroidDevice) say_hello() {
	device.simple_call('shell echo Hello, world!')
}

fn (device AndroidDevice) simple_call(device_command string) {
	cmd_base := '-s ' + device.serial

	println(execute('$cmd_base $device_command'))
}

fn (device AndroidDevice) str() string {
	// Obfucate the serial number
	return 'AndroidDevice{serial: ...' + device.serial#[-4..] + '}'
}
