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

module cache

struct Cache {
mut:
	string_cache map[string]string
	debug        bool
}

const (
	global_cache = &Cache{}
)

pub fn get_string(key string) string {
	c := get_global_cache()
	if key in c.string_cache.keys() {
		debug_print(@MOD + '.' + @FN + '($key) get cached')
		return c.string_cache[key]
	}
	debug_print(@MOD + '.' + @FN + '($key) get non cached')
	return ''
}

pub fn set_string(key string, data string) {
	mut c := get_global_cache()
	debug_print(@MOD + '.' + @FN + '($key) caching')
	c.string_cache[key] = data
}

pub fn debug_cache(debug bool) {
	get_global_cache().debug = debug
}

fn get_global_cache() &Cache {
	mut c := &Cache(0)
	unsafe {
		c = cache.global_cache
	}
	return c
}

fn debug_print(msg string) {
	if get_global_cache().debug {
		println(msg)
	}
}
