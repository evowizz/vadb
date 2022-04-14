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

module sdk

import cache
import os

const (
	possible_sdk_paths = [
		os.getenv('ANDROID_SDK_ROOT'),
		os.join_path(os.getenv('LOCALAPPDATA'), 'Local\\Android\\sdk'),
	]
)

fn root() string {
	mut sdk_root := cache.get_string(@MOD + '.' + @FN)

	if sdk_root == '' {
		for dir in sdk.possible_sdk_paths {
			if os.exists(dir) && os.is_dir(dir) {
				cache.set_string(@MOD + '.' + @FN, dir)
				return dir
			}
		}
	}

	if os.is_dir(sdk_root) {
		return sdk_root
	}

	return ''
}

fn found() bool {
	return root() != ''
}

fn platform_tools_path() string {
	if !found() {
		return ''
	}

	return os.join_path(root(), 'platform-tools')
}

pub fn adb_path() string {
	if !found() {
		return ''
	}

	return os.join_path(platform_tools_path(), 'adb.exe')
}
