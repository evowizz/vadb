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
import os
import szip

fn test_unzip_apkm() {
	input_file := 'my_apkm.apkm'
	base_path := get_test_path()

	input, output := check_input(base_path, input_file, '.apkm') or { panic(err) }
	extract_content(input, output, '.apk') or { panic(err) }

	output_content := os.ls(output) or { panic(err) }
	for content in output_content {
		// Checking with os.file_ext instead of string.ends_with to print
		// the file extension in the error message
		assert os.file_ext(content) == '.apk'
	}
}

fn extract_content(input_zip string, output_dir string, extension_filters ...string) ?bool {
	mut zip := szip.open(input_zip, szip.CompressionLevel.no_compression, szip.OpenMode.read_only) ?
	total := zip.total() or { return false }

	for i in 0 .. total {
		zip.open_entry_by_index(i) or { continue }

		if zip.is_dir() or { true } {
			continue
		}

		// Ignore files that don't match the extension filters
		if extension_filters.len > 0 {
			entry_extension := os.file_ext(zip.name())
			if entry_extension !in extension_filters {
				continue
			}
		}

		extract_zip_entry(mut zip, output_dir) ?
	}

	zip.close()
	return true
}

fn extract_zip_entry(mut zip szip.Zip, output_dir string) ? {
	dst_name := zip.name()
	dst := os.real_path(os.join_path(output_dir, dst_name))
	dst_dir := os.dir(dst)

	if !os.exists(dst_dir) {
		os.mkdir_all(dst_dir) or { return }
	}

	os.write_file(dst, '') or { return error('Cannot create file $dst_name') }

	zip.extract_entry(dst) ?
	zip.close_entry()
}

fn check_input(base string, input string, ext string) ?(string, string) {
	input_ext := os.file_ext(input)

	if input_ext != ext {
		return error('Input ($input) file extension is not ' + ext)
	}

	// Example: tests/gmail.apkm -> tests/gmail_output
	input_file := os.join_path(base, input)
	output_dir := os.join_path(base, input.all_before(ext) + '_output')

	if !os.exists(input_file) {
		return error('Input ($input) file does not exist')
	}

	if os.exists(output_dir) {
		os.rmdir_all(output_dir) ?
	}

	os.mkdir(output_dir) ?

	return input_file, output_dir
}

fn get_test_path() string {
	return os.dir(@FILE)
}
