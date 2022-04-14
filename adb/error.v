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

struct NoUniqueDevice {
	Error
}

fn (err NoUniqueDevice) msg() string {
	return 'Could not find unique device'
}

[inline]
pub fn no_unique_device_error() IError {
	return IError(NoUniqueDevice{})
}

struct DeviceNotFound {
	Error
}

fn (err DeviceNotFound) msg() string {
	return 'Could not find device'
}

[inline]
pub fn device_not_found_error() IError {
	return IError(DeviceNotFound{})
}
