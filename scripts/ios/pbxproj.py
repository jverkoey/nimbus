#!/usr/bin/env python
# encoding: utf-8
"""
pbxproj.py

Working with the pbxproj file format is a pain in the ass.

This script provides a couple basic features for parsing pbxproj files:

* Getting a dependency list
* Adding one pbxproj to another pbxproj as a dependency

Version 1.2.

History:
1.0 - October 20, 2010: Initial hacked-together version finished. It is alive!
1.1 - January 11, 2011: Add configuration settings to all configurations by default.
1.2 - June 7, 2011: Rewrote the pbxproj family of code as an ios module and made the class
                    more generic (no assumptions made about the project layout).

Branched from Three20's ttmodule script 2011-06-07.
Created by Jeff Verkoeyen on 2010-10-18.
Copyright 2011 Jeff Verkoeyen
Copyright 2009-2011 Facebook

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import hashlib
import logging
import os
import re
import sys
from relpath import relpath

pbxproj_cache = {}

class PbxprojTarget(object):
	def __init__(self, name, project, guid = None):
		self._name = name
		self._project = project
		
		# This target's GUID.
		self._guid = guid
		
		# The configuration list GUID points to the list of configurations for a given target.
		self._configuration_list_guid = None
		
		# The list of configuration GUIDs for this target.
		self._configuration_guids = None
		
		# The GUID for the resources build phase.
		self._resources_build_phase_guid = None
		
		# The GUID for the frameworks builds phase.
		self._frameworks_build_phase_guid = None
		
		# An array of dependency GUIDs.
		self._dependency_guids = None
		
		# An array of dependency names in the same order as the dependency guids array.
		self._dependency_names = None
		
		# An array of path:target strings.
		self._dependency_paths = None
		
		# This target's product GUID.
		self._product_guid = None
		
		# This target's product name.
		self._product_name = None


	def name(self):
		return self._name


	def configuration_list_guid(self):
		if self._configuration_list_guid is None:
			project_data = project.get_project_data()

			result = re.search('[A-Z0-9]+ \/\* '+re.escape(self._name)+' \*\/ = {\n[ \t]+isa = PBXNativeTarget;(?:.|\n)+?buildConfigurationList = ([A-Z0-9]+) \/\* Build configuration list for PBXNativeTarget "'+re.escape(self._name)+'" \*\/;',
			                   project_data)

			if result:
				(self._configuration_list_guid, ) = result.groups()
			else:
				# False indicates that we could not find a configuration list GUID.
				self._configuration_list_guid = False
		
		return self._configuration_list_guid


	def configuration_guids(self):
		if not self._configuration_guids and self.configuration_list_guid():
			project_data = project.get_project_data()

			match = re.search(re.escape(self.configuration_list_guid())+' \/\* Build configuration list for PBXNativeTarget "'+re.escape(self._name)+'" \*\/ = \{\n[ \t]+isa = XCConfigurationList;\n[ \t]+buildConfigurations = \(\n((?:.|\n)+?)\);', project_data)
			if not match:
				logging.error("Couldn't find the configuration list for the project.")
				return False

			(configuration_list,) = match.groups()
			self._configuration_guids = re.findall('[ \t]+([A-Z0-9]+) \/\* (.+) \*\/,\n', configuration_list)
		
		return self._configuration_guids


	def guid(self):
		if not self._guid:
			project_data = self._project.get_project_data()
			result = re.search('([A-Z0-9]+) \/\* '+re.escape(self._name)+' \*\/ = {\n[ \t]+isa = PBXNativeTarget;(?:.|\n)+?buildPhases =',
			                   project_data)
	
			if not result:
				logging.error("Can't recover: Unable to find the GUID for the target named \""+self._name+"\" from the project loaded from: "+self._project.path())
				return False

			(self._guid, ) = result.groups()
		
		return self._guid


	def _gather_build_phases(self):	
		project_data = self._project.get_project_data()
		
		result = re.search('[A-Z0-9]+ \/\* '+re.escape(self._name)+' \*\/ = {\n[ \t]+isa = PBXNativeTarget;(?:.|\n)+?buildPhases = \(\n((?:.|\n)+?)\);',
		                   project_data)
	
		if not result:
			logging.error("Can't recover: Unable to find the build phases for the target named \""+self._name+"\" from the project loaded from: "+self._project.path())
			return False

		(build_phases, ) = result.groups()

		# Get the build phases we care about.

		match = re.search('([A-Z0-9]+) \/\* Resources \*\/', build_phases)
		if match:
			(self._resources_build_phase_guid, ) = match.groups()
		else:
			self._resources_build_phase_guid = False
		
		match = re.search('([A-Z0-9]+) \/\* Frameworks \*\/', build_phases)
		if not match:
			logging.error("Couldn't find the Frameworks phase for the target named \""+self._name+"\" from the project loaded from: "+self._project.path())
			logging.error("Please add a New Link Binary With Libraries Build Phase to your target")
			logging.error("Right click your target in the project, then click Add, then New Build Phase,")
			logging.error("  \"New Link Binary With Libraries Build Phase\"")
			return False

		(self._frameworks_build_phase_guid, ) = match.groups()


	def resources_build_phase_guid(self):
		if not self._resources_build_phase_guid:
			self._gather_build_phases()
		
		return self._resources_build_phase_guid


	def frameworks_build_phase_guid(self):
		if not self._frameworks_build_phase_guid:
			self._gather_build_phases()
		
		return self._frameworks_build_phase_guid


	def dependency_guids(self):
		if not self._dependency_guids:
			project_data = self._project.get_project_data()

			result = re.search(re.escape(self.guid())+' \/\* '+re.escape(self._name)+' \*\/ = {\n[ \t]+isa = PBXNativeTarget;(?:.|\n)+?dependencies = \(\n((?:[ \t]+[A-Z0-9]+ \/\* PBXTargetDependency \*\/,\n)*)[ \t]*\);\n',
			                   project_data)
	
			if not result:
				logging.error("Unable to get dependencies from: "+self._project.path())
				return False
	
			(dependency_set, ) = result.groups()
			self._dependency_guids = re.findall('[ \t]+([A-Z0-9]+) \/\* PBXTargetDependency \*\/,\n', dependency_set)
		
		return self._dependency_guids


	def dependency_names(self):
		if not self._dependency_names:
			project_data = self._project.get_project_data()
			dependency_names = []

			for guid in self.dependency_guids():
				result = re.search(guid+' \/\* PBXTargetDependency \*\/ = \{\n[ \t]+isa = PBXTargetDependency;\n[ \t]*name = (["a-zA-Z0-9\.\-]+);',
				                   project_data)

				if result:
					(dependency_name, ) = result.groups()
					dependency_names.append(dependency_name)

			self._dependency_names = dependency_names
		
		return self._dependency_names

	def dependency_paths(self):
		if self._dependency_paths:
			return self._dependency_paths

		dependency_guids = self.dependency_guids()
		if dependency_guids:
			project_data = self._project.get_project_data()
			
			target_proxy_guids = []
			
			for guid in dependency_guids:
				result = re.search(guid+' \/\* PBXTargetDependency \*\/ = \{\n(?:.|\n)+?targetProxy = ([A-Z0-9]+) \/\* PBXContainerItemProxy \*\/;',
				                   project_data)
				
				if result:
					(target_proxy_guid, ) = result.groups()
					target_proxy_guids.append(target_proxy_guid)

			container_portal_guids = []
			remote_guids = []
			
			for guid in target_proxy_guids:
				result = re.search(guid+' \/\* PBXContainerItemProxy \*\/ = \{\n(?:.|\n)+?containerPortal = ([A-Z0-9]+) \/\* .+? \*\/;(?:.|\n)+?remoteGlobalIDString = ([A-Z0-9]+)',
				                   project_data)
				
				if result:
					(container_portal_guid, remote_guid, ) = result.groups()
					container_portal_guids.append(container_portal_guid)
					remote_guids.append(remote_guid)

			dependency_paths = []

			index = 0
			for guid in container_portal_guids:
				result = re.search(guid+' \/\* .+? \*\/ = {isa = PBXFileReference; lastKnownFileType = "wrapper.pb-project"; name = .+?; path = (.+?); sourceTree = .+?; };',
				                   project_data)
				
				if result:
					(dependency_path, ) = result.groups()
					dependency_path = dependency_path + ":" + remote_guids[index]
					dependency_paths.append(dependency_path)
				else:
					logging.error("Unable to find the path for GUID: "+guid)
				
				index += 1

			if len(dependency_paths) != len(container_portal_guids):
				logging.error("Unable to load all dependency information from the project.")
				return False

			self._dependency_paths = dependency_paths
			
		elif dependency_guids is not None and dependency_guids is not False and len(dependency_guids) == 0:
			self._dependency_paths = []

		return self._dependency_paths


	def _gather_product_details(self):
		project_data = self._project.get_project_data()

		result = re.search(re.escape(self.guid())+' \/\* '+re.escape(self._name)+' \*\/ = {\n[ \t]+isa = PBXNativeTarget;(?:.|\n)+?productReference = ([A-Z0-9]+) \/\* (.+?) \*\/;',
		                   project_data)

		if not result:
			logging.error("Unable to get product guid from: "+self.path())
			return False

		(self._product_guid, self._product_name, ) = result.groups()
		
		return True


	def product_guid(self):
		if not self._product_guid:
			self._gather_product_details()

		return self._product_guid


	def product_name(self):
		if not self._product_name:
			self._gather_product_details()

		return self._product_name


class pbxproj(object):

	@staticmethod
	def get_pbxproj_by_path(path, xcode_version = None):
		if path not in pbxproj_cache:
			pbxproj_cache[path] = pbxproj(path, xcode_version = xcode_version)

		return pbxproj_cache[path]

	def __init__(self, path, xcode_version = None):
		# The contents of the pbxproj file loaded into memory.
		self._project_data = None
		
		self._active_target = None
		
		self._project_name = os.path.basename(os.path.dirname(path)).replace('.xcodeproj', '')

		# The path to the pbxproj file.
		self._path = path

		# Mapping of target names to PbxprojTarget objects.
		self._targets_by_name = {}
		
		# Mapping of target guids to PbxprojTarget objects.
		self._targets_by_guid = {}
		
		# ???
		self._xcode_version = xcode_version
		
		# The file format version for this project.
		self._file_format_version = None

		self._is_loaded = self._load_from_disk()

	def __str__(self):
		details = "\t   path: \""+str(self._path)+"\"\n\ttargets:"
		for target_name in self._targets_by_name:
			target = self._targets_by_name[target_name]
			details += "\n            -> "+target.name() + " ("+target.guid()+")"
		if self._active_target:
			details += "\n  active target: "+self._active_target
		return details

	def is_loaded(self):
		return self._is_loaded

	def uniqueid_for_target(self, target):
		return self._path + ':' + target

	def path(self):
		return self._path

	def active_target(self):
		if self._active_target is None:
			return None
		
		return self.target_by_name(self._active_target)

	def set_active_target(self, target_name):
		self._active_target = target_name

	# A pbxproj file is contained within an xcodeproj file.
	# This method simply strips off the project.pbxproj part of the path.
	def xcodeprojpath(self):
		return os.path.dirname(self.path())

	def version(self):
		if not self._file_format_version:
			result = re.search('\tobjectVersion = ([0-9]+);', project_data)

			if not result:
				logging.error("Can't recover: unable to find the project version for your target at: "+self.path())
				return False
	
			(self._file_format_version,) = result.groups()
			self._file_format_version = int(self._file_format_version)

		return self._file_format_version

	# Fetch a specific target by its name.
	def target_by_name(self, name):
		if name in self._targets_by_guid:
			target = self._targets_by_guid[name]
			target._guid = name
			return target

		if name not in self._targets_by_name:
			target = PbxprojTarget(name, self)
			self._targets_by_name[name] = target
			self._targets_by_guid[target.guid()] = target
		
		return self._targets_by_name[name]

	# Load the project data from disk.
	def get_project_data(self):
		if self._project_data is None:
			if not os.path.exists(self.path()):
				logging.info("Couldn't find the project at this path:")
				logging.info(self.path())
				return None

			project_file = open(self.path(), 'r')
			self._project_data = project_file.read()

		return self._project_data

	# Write the project data to disk.
	def set_project_data(self, project_data, flush=False):
		if self._project_data != project_data or flush:
			self._project_data = project_data
			if flush:
				project_file = open(self.path(), 'w')
				project_file.write(self._project_data)

	def _load_from_disk(self):
		project_data = self.get_project_data()

		if project_data is None:
			logging.error("Can't recover: unable to load the project data from disk, check the path:\n    path: \""+self.path()+"\"")
			return False

		self._gather_all_targets()

		return True

	def _gather_all_targets(self):
		project_data = self.get_project_data()
		
		result = re.search('targets = \(\n((?:.|\n)+?)\);',
		                   project_data)
		
		if not result:
			logging.error("Couldn't find any targets.")
			return None
		
		(target_list, ) = result.groups()

		targets = re.findall('([A-Z0-9]+) \/\* (.+?) \*\/', target_list)
		if not targets:
			logging.error("Unable to read the targets.")
			return None
		
		for target in targets:
			name = target[1]
			target = PbxprojTarget(name, project = self, guid = target[0])
			self._targets_by_name[name] = target
			self._targets_by_guid[target.guid()] = target

		return True


	def dependency_names_for_target_name(self, target_name):
		target = self.target_by_name(target_name)
		return target.dependency_names()


	def dependency_paths_for_target_name(self, target_name):
		target = self.target_by_name(target_name)
		return target.dependency_paths()


	# Add a line to the PBXBuildFile section.
	#
	# <default_guid> /* <name> in Frameworks */ = {isa = PBXBuildFile; fileRef = <file_ref_hash> /* <name> */; };
	#
	# Returns: <default_guid> if a line was added.
	#          Otherwise, the existing guid is returned.
	def add_buildfile(self, name, file_ref_hash, default_guid):
		project_data = self.get_project_data()

		match = re.search('\/\* Begin PBXBuildFile section \*\/\n((?:.|\n)+?)\/\* End PBXBuildFile section \*\/', project_data)

		if not match:
			logging.error("Couldn't find PBXBuildFile section.")
			return None

		(subtext, ) = match.groups()

		buildfile_hash = None
		
		match = re.search('([A-Z0-9]+).+?fileRef = '+re.escape(file_ref_hash), subtext)
		if match:
			(buildfile_hash, ) = match.groups()
			logging.info("This build file already exists: "+buildfile_hash)
		
		if buildfile_hash is None:
			match = re.search('\/\* Begin PBXBuildFile section \*\/\n', project_data)

			buildfile_hash = default_guid
		
			libfiletext = "\t\t"+buildfile_hash+" /* "+name+" in Frameworks */ = {isa = PBXBuildFile; fileRef = "+file_ref_hash+" /* "+name+" */; };\n"
			project_data = project_data[:match.end()] + libfiletext + project_data[match.end():]
		
		self.set_project_data(project_data)
		
		return buildfile_hash

	# Add a line to the PBXFileReference section.
	#
	# <default_guid> /* <name> */ = {isa = PBXFileReference; lastKnownFileType = "wrapper.<file_type>"; name = <name>; path = <rel_path>; sourceTree = <source_tree>; };
	#
	# Returns: <default_guid> if a line was added.
	#          Otherwise, the existing guid is returned.
	def add_filereference(self, name, file_type, default_guid, rel_path, source_tree):
		project_data = self.get_project_data()

		quoted_rel_path = '"'+rel_path.strip('"')+'"'

		fileref_hash = None

		match = re.search('([A-Z0-9]+) \/\* '+re.escape(name)+' \*\/ = \{isa = PBXFileReference; lastKnownFileType = "wrapper.'+file_type+'"; name = '+re.escape(name)+'; path = '+re.escape(rel_path)+';', project_data)

		if not match:
			# Check again for quoted versions, just to be sure.
			match = re.search('([A-Z0-9]+) \/\* '+re.escape(name)+' \*\/ = \{isa = PBXFileReference; lastKnownFileType = "wrapper.'+file_type+'"; name = '+re.escape(name)+'; path = '+re.escape(quoted_rel_path)+';', project_data)

		if match:
			logging.info("This file has already been added.")
			(fileref_hash, ) = match.groups()
			
		else:
			match = re.search('\/\* Begin PBXFileReference section \*\/\n', project_data)

			if not match:
				logging.error("Couldn't find the PBXFileReference section.")
				return False

			fileref_hash = default_guid
			
			pbxfileref = "\t\t"+fileref_hash+" /* "+name+" */ = {isa = PBXFileReference; lastKnownFileType = \"wrapper."+file_type+"\"; name = "+name+"; path = "+quoted_rel_path+"; sourceTree = "+source_tree+"; };\n"

			project_data = project_data[:match.end()] + pbxfileref + project_data[match.end():]

		self.set_project_data(project_data)

		return fileref_hash

	# Add a file to the given PBXGroup.
	#
	# <guid> /* <name> */,
	def add_file_to_group(self, name, guid, group):
		project_data = self.get_project_data()

		match = re.search('\/\* '+re.escape(group)+' \*\/ = \{\n[ \t]+isa = PBXGroup;\n[ \t]+children = \(\n((?:.|\n)+?)\);', project_data)
		if not match:
			logging.error("Couldn't find the "+group+" children.")
			return False

		(children,) = match.groups()
		match = re.search(re.escape(guid), children)
		if match:
			logging.info("This file is already a member of the "+name+" group.")
		else:
			match = re.search('\/\* '+re.escape(group)+' \*\/ = \{\n[ \t]+isa = PBXGroup;\n[ \t]+children = \(\n', project_data)

			if not match:
				logging.error("Couldn't find the "+group+" group.")
				return False

			pbxgroup = "\t\t\t\t"+guid+" /* "+name+" */,\n"
			project_data = project_data[:match.end()] + pbxgroup + project_data[match.end():]

		self.set_project_data(project_data)

		return True

	# Add a file to the Frameworks PBXGroup.
	#
	# <guid> /* <name> */,
	def add_file_to_frameworks(self, name, guid):
		return self.add_file_to_group(name, guid, 'Frameworks')

	# Add a file to the Resources PBXGroup.
	#
	# <guid> /* <name> */,
	def add_file_to_resources(self, name, guid):
		match = re.search('\/\* '+re.escape('Resources')+' \*\/ = \{\n[ \t]+isa = PBXGroup;\n[ \t]+children = \(\n((?:.|\n)+?)\);', self.get_project_data())
		if not match:
			return self.add_file_to_group(name, guid, 'Supporting Files')

		return self.add_file_to_group(name, guid, 'Resources')

	def add_file_to_phase(self, name, guid, phase_guid, phase):
		project_data = self.get_project_data()

		match = re.search(re.escape(phase_guid)+" \/\* "+re.escape(phase)+" \*\/ = {(?:.|\n)+?files = \(((?:.|\n)+?)\);", project_data)

		if not match:
			logging.error("Couldn't find the "+phase+" phase.")
			return False

		(files, ) = match.groups()

		match = re.search(re.escape(guid), files)
		if match:
			logging.info("The file has already been added.")
		else:
			match = re.search(re.escape(phase_guid)+" \/\* "+phase+" \*\/ = {(?:.|\n)+?files = \(\n", project_data)
			if not match:
				logging.error("Couldn't find the "+phase+" files")
				return False

			frameworktext = "\t\t\t\t"+guid+" /* "+name+" in "+phase+" */,\n"
			project_data = project_data[:match.end()] + frameworktext + project_data[match.end():]

		self.set_project_data(project_data)

		return True

	def get_rel_path_to_products_dir(self):
		project_path = os.path.dirname(os.path.abspath(self.xcodeprojpath()))
		build_path = os.path.join(os.path.join(os.path.dirname(Paths.src_dir), 'Build'), 'Products')
		return relpath(project_path, build_path)

	def add_file_to_frameworks_phase(self, name, guid):
		target = self.active_target()
		return self.add_file_to_phase(name, guid, target.frameworks_build_phase_guid(), 'Frameworks')

	def add_file_to_resources_phase(self, name, guid):
		if self._resources_guid is None:
			logging.error("No resources build phase found in the destination project")
			logging.error("Please add a New Copy Bundle Resources Build Phase to your target")
			logging.error("Right click your target in the project, Add, New Build Phase,")
			logging.error("  \"New Copy Bundle Resources Build Phase\"")
			return False

		return self.add_file_to_phase(name, guid, self._resources_guid, 'Resources')

	def add_header_search_path(self, configuration):
		project_path = os.path.dirname(os.path.abspath(self.xcodeprojpath()))
		build_path = os.path.join(os.path.join(os.path.join(os.path.dirname(Paths.src_dir), 'Build'), 'Products'), 'three20')
		rel_path = relpath(project_path, build_path)

		did_add_build_setting = self.add_build_setting(configuration, 'HEADER_SEARCH_PATHS', '"'+rel_path+'"')
		if not did_add_build_setting:
			return did_add_build_setting
		
		# Version 46 is Xcode 4's file format.
		try:
			primary_version = int(self._xcode_version.split('.')[0])
		except ValueError, e:
			primary_version = 0
		if self._file_format_version >= 46 or primary_version >= 4:
			did_add_build_setting = self.add_build_setting(configuration, 'HEADER_SEARCH_PATHS', '"$(BUILT_PRODUCTS_DIR)/../../three20"')
			if not did_add_build_setting:
				return did_add_build_setting

			did_add_build_setting = self.add_build_setting(configuration, 'HEADER_SEARCH_PATHS', '"$(BUILT_PRODUCTS_DIR)/../three20"')
			if not did_add_build_setting:
				return did_add_build_setting

		return did_add_build_setting
	
	def add_build_setting(self, configuration, setting_name, value):
		project_data = self.get_project_data()

		match = re.search('\/\* '+configuration+' \*\/ = {\n[ \t]+isa = XCBuildConfiguration;\n[ \t]+buildSettings = \{\n((?:.|\n)+?)\};', project_data)
		if not match:
			logging.error("Couldn't find this configuration.")
			return False

		settings_start = match.start(1)
		settings_end = match.end(1)

		(build_settings, ) = match.groups()

		match = re.search(re.escape(setting_name)+' = ((?:.|\n)+?);', build_settings)

		if not match:
			# Add a brand new build setting. No checking for existing settings necessary.
			settingtext = '\t\t\t\t'+setting_name+' = '+value+';\n'

			project_data = project_data[:settings_start] + settingtext + project_data[settings_start:]
		else:
			# Build settings already exist. Is there one or many?
			(search_paths,) = match.groups()
			if re.search('\(\n', search_paths):
				# Many
				match = re.search(re.escape(value), search_paths)
				if not match:
					# If value has any spaces in it, Xcode will split it up into
					# multiple entries.
					escaped_value = re.escape(value).replace(' ', '",\n[ \t]+"')
					match = re.search(escaped_value, search_paths)
					if not match and not re.search(re.escape(value.strip('"')), search_paths):
						match = re.search(re.escape(setting_name)+' = \(\n', build_settings)

						build_settings = build_settings[:match.end()] + '\t\t\t\t\t'+value+',\n' + build_settings[match.end():]
						project_data = project_data[:settings_start] + build_settings + project_data[settings_end:]
			else:
				# One
				if search_paths.strip('"') != value.strip('"'):
					existing_path = search_paths
					path_set = '(\n\t\t\t\t\t'+value+',\n\t\t\t\t\t'+existing_path+'\n\t\t\t\t)'
					build_settings = build_settings[:match.start(1)] + path_set + build_settings[match.end(1):]
					project_data = project_data[:settings_start] + build_settings + project_data[settings_end:]

		self.set_project_data(project_data)

		return True

	def get_hash_base(self, uniquename):
		examplehash = '320FFFEEEDDDCCCBBBAAA000'
		uniquehash = hashlib.sha224(uniquename).hexdigest().upper()
		uniquehash = uniquehash[:len(examplehash) - 4]
		return '320'+uniquehash

	def add_framework(self, framework):
		tthash_base = self.get_hash_base(framework)
		
		fileref_hash = self.add_filereference(framework, 'frameworks', tthash_base+'0', 'System/Library/Frameworks/'+framework, 'SDKROOT')
		libfile_hash = self.add_buildfile(framework, fileref_hash, tthash_base+'1')
		if not self.add_file_to_frameworks(framework, fileref_hash):
			return False
		
		if not self.add_file_to_frameworks_phase(framework, libfile_hash):
			return False
		
		return True

	def add_bundle(self):
		tthash_base = self.get_hash_base('Three20.bundle')

		project_path = os.path.dirname(os.path.abspath(self.xcodeprojpath()))
		build_path = os.path.join(Paths.src_dir, 'Three20.bundle')
		rel_path = relpath(project_path, build_path)
		
		fileref_hash = self.add_filereference('Three20.bundle', 'plug-in', tthash_base+'0', rel_path, 'SOURCE_ROOT')

		libfile_hash = self.add_buildfile('Three20.bundle', fileref_hash, tthash_base+'1')

		if not self.add_file_to_resources('Three20.bundle', fileref_hash):
			return False

		if not self.add_file_to_resources_phase('Three20.bundle', libfile_hash):
			return False

		return True

	# Get the PBXFileReference from the given PBXBuildFile guid.
	def get_filerefguid_from_buildfileguid(self, buildfileguid):
		project_data = self.get_project_data()
		match = re.search(buildfileguid+' \/\* .+ \*\/ = {isa = PBXBuildFile; fileRef = ([A-Z0-9]+) \/\* .+ \*\/;', project_data)

		if not match:
			logging.error("Couldn't find PBXBuildFile row.")
			return None

		(filerefguid, ) = match.groups()
		
		return filerefguid

	def get_filepath_from_filerefguid(self, filerefguid):
		project_data = self.get_project_data()
		match = re.search(filerefguid+' \/\* .+ \*\/ = {isa = PBXFileReference; .+ path = (.+); .+ };', project_data)

		if not match:
			logging.error("Couldn't find PBXFileReference row.")
			return None

		(path, ) = match.groups()
		
		return path


	# Get all source files that are "built" in this project. This includes files built for
	# libraries, executables, and unit testing.
	def get_built_sources(self):
		project_data = self.get_project_data()
		match = re.search('\/\* Begin PBXSourcesBuildPhase section \*\/\n((?:.|\n)+?)\/\* End PBXSourcesBuildPhase section \*\/', project_data)

		if not match:
			logging.error("Couldn't find PBXSourcesBuildPhase section.")
			return None
		
		(buildphasedata, ) = match.groups()
		
		buildfileguids = re.findall('[ \t]+([A-Z0-9]+) \/\* .+ \*\/,\n', buildphasedata)
		
		project_path = os.path.dirname(os.path.abspath(self.xcodeprojpath()))
		
		filenames = []
		
		for buildfileguid in buildfileguids:
			filerefguid = self.get_filerefguid_from_buildfileguid(buildfileguid)
			filepath = self.get_filepath_from_filerefguid(filerefguid)

			filenames.append(os.path.join(project_path, filepath.strip('"')))

		return filenames


	# Get all header files that are "built" in this project. This includes files built for
	# libraries, executables, and unit testing.
	def get_built_headers(self):
		project_data = self.get_project_data()
		match = re.search('\/\* Begin PBXHeadersBuildPhase section \*\/\n((?:.|\n)+?)\/\* End PBXHeadersBuildPhase section \*\/', project_data)

		if not match:
			logging.error("Couldn't find PBXHeadersBuildPhase section.")
			return None
		
		(buildphasedata, ) = match.groups()

		buildfileguids = re.findall('[ \t]+([A-Z0-9]+) \/\* .+ \*\/,\n', buildphasedata)
		
		project_path = os.path.dirname(os.path.abspath(self.xcodeprojpath()))
		
		filenames = []
		
		for buildfileguid in buildfileguids:
			filerefguid = self.get_filerefguid_from_buildfileguid(buildfileguid)
			filepath = self.get_filepath_from_filerefguid(filerefguid)
			
			filenames.append(os.path.join(project_path, filepath.strip('"')))

		return filenames


	def add_dependency(self, dep):
		project_data = self.get_project_data()
		dep_data = dep.get_project_data()
		project_target = self.active_target()
		dep_target = dep.active_target()
		
		if project_data is None or dep_data is None:
			return False

		logging.info("\nAdding "+str(dep)+"\nto\n"+str(self))
		
		project_path = os.path.dirname(os.path.abspath(self.xcodeprojpath()))
		dep_path = os.path.abspath(dep.xcodeprojpath())
		rel_path = relpath(project_path, dep_path)
		
		logging.info("")
		logging.info("Project path:    "+project_path)
		logging.info("Dependency path: "+dep_path)
		logging.info("Relative path:   "+rel_path)
		
		tthash_base = self.get_hash_base(dep.uniqueid_for_target(dep._active_target))
	
		###############################################
		logging.info("")
		logging.info("Step 1: Add file reference to the dependency...")
		
		pbxfileref_hash = self.add_filereference(dep._project_name+'.xcodeproj', 'pb-project', tthash_base+'0', rel_path, 'SOURCE_ROOT')
		project_data = self.get_project_data()

		logging.info("Done: Added file reference: "+pbxfileref_hash)
		self.set_project_data(project_data)
		
		###############################################
		logging.info("")
		logging.info("Step 2: Add file to Frameworks group...")
		
		if not self.add_file_to_frameworks(dep._project_name+".xcodeproj", pbxfileref_hash):
			return False
		project_data = self.get_project_data()

		logging.info("Done: Added file to Frameworks group.")
		self.set_project_data(project_data)
		
		###############################################
		logging.info("")
		logging.info("Step 3: Add dependencies...")
		
		pbxtargetdependency_hash = None
		pbxcontaineritemproxy_hash = None
		
		match = re.search('\/\* Begin PBXTargetDependency section \*\/\n((?:.|\n)+?)\/\* End PBXTargetDependency section \*\/', project_data)
		if not match:
			logging.info("\tAdding a PBXTargetDependency section...")
			match = re.search('\/\* End PBXSourcesBuildPhase section \*\/\n', project_data)
			
			if not match:
				logging.error("Couldn't find the PBXSourcesBuildPhase section.")
				return False
			
			project_data = project_data[:match.end()] + "\n/* Begin PBXTargetDependency section */\n\n/* End PBXTargetDependency section */\n" + project_data[match.end():]
		else:
			(subtext, ) = match.groups()
			match = re.search('([A-Z0-9]+) \/\* PBXTargetDependency \*\/ = {\n[ \t]+isa = PBXTargetDependency;\n[ \t]+name = '+re.escape(dep._project_name)+';\n[ \t]+targetProxy = ([A-Z0-9]+) \/\* PBXContainerItemProxy \*\/;', project_data)
			if match:
				(pbxtargetdependency_hash, pbxcontaineritemproxy_hash,) = match.groups()
				logging.info("This dependency already exists.")

		self.set_project_data(project_data)

		if pbxtargetdependency_hash is None or pbxcontaineritemproxy_hash is None:
			match = re.search('\/\* Begin PBXTargetDependency section \*\/\n', project_data)
		
			pbxtargetdependency_hash = tthash_base+'1'
			pbxcontaineritemproxy_hash = tthash_base+'2'
		
			pbxtargetdependency = "\t\t"+pbxtargetdependency_hash+" /* PBXTargetDependency */ = {\n\t\t\tisa = PBXTargetDependency;\n\t\t\tname = "+dep._project_name+";\n\t\t\ttargetProxy = "+pbxcontaineritemproxy_hash+" /* PBXContainerItemProxy */;\n\t\t};\n"
			project_data = project_data[:match.end()] + pbxtargetdependency + project_data[match.end():]

		logging.info("Done: Added dependency.")
		self.set_project_data(project_data)


		###############################################
		logging.info("")
		logging.info("Step 3.1: Add container proxy for dependencies...")

		containerExists = False

		match = re.search('\/\* Begin PBXContainerItemProxy section \*\/\n((?:.|\n)+?)\/\* End PBXContainerItemProxy section \*\/', project_data)
		if not match:
			logging.info("\tAdding a PBXContainerItemProxy section...")
			match = re.search('\/\* End PBXBuildFile section \*\/\n', project_data)
			
			if not match:
				logging.error("Couldn't find the PBXBuildFile section.")
				return False
			
			project_data = project_data[:match.end()] + "\n/* Begin PBXContainerItemProxy section */\n\n/* End PBXContainerItemProxy section */\n" + project_data[match.end():]
		else:
			(subtext, ) = match.groups()
			match = re.search(re.escape(pbxcontaineritemproxy_hash), subtext)
			if match:
				logging.info("This container proxy already exists.")
				containerExists = True

		self.set_project_data(project_data)

		if not containerExists:
			match = re.search('\/\* Begin PBXContainerItemProxy section \*\/\n', project_data)

			pbxcontaineritemproxy = "\t\t"+pbxcontaineritemproxy_hash+" /* PBXContainerItemProxy */ = {\n\t\t\tisa = PBXContainerItemProxy;\n\t\t\tcontainerPortal = "+pbxfileref_hash+" /* "+dep._project_name+".xcodeproj */;\n\t\t\tproxyType = 1;\n\t\t\tremoteGlobalIDString = "+dep_target.guid()+";\n\t\t\tremoteInfo = "+dep._project_name+";\n\t\t};\n"
			project_data = project_data[:match.end()] + pbxcontaineritemproxy + project_data[match.end():]

		logging.info("Done: Added container proxy.")
		self.set_project_data(project_data)


		###############################################
		logging.info("")
		logging.info("Step 3.2: Add module to the dependency list...")

		match = re.search(project_target.guid()+' \/\* .+? \*\/ = {\n[ \t]+(?:.|\n)+?[ \t]+dependencies = \(\n((?:.|\n)+?)\);', project_data)
		
		dependency_exists = False
		
		if not match:
			logging.error("Couldn't find the dependency list.")
			return False
		else:
			(dependencylist, ) = match.groups()
			match = re.search(re.escape(pbxtargetdependency_hash), dependencylist)
			if match:
				logging.info("This dependency has already been added.")
				dependency_exists = True
		
		if not dependency_exists:
			match = re.search(project_target.guid()+' \/\* .+? \*\/ = {\n[ \t]+(?:.|\n)+?[ \t]+dependencies = \(\n', project_data)

			if not match:
				logging.error("Couldn't find the dependency list.")
				return False

			dependency_item = '\t\t\t\t'+pbxtargetdependency_hash+' /* PBXTargetDependency */,\n'
			project_data = project_data[:match.end()] + dependency_item + project_data[match.end():]

		logging.info("Done: Added module to the dependency list.")
		self.set_project_data(project_data)


		###############################################
		logging.info("")
		logging.info("Step 4: Create project references...")

		match = re.search('\/\* Begin PBXProject section \*\/\n((?:.|\n)+?)\/\* End PBXProject section \*\/', project_data)
		if not match:
			logging.error("Couldn't find the project section.")
			return False

		project_start = match.start(1)
		project_end = match.end(1)

		(project_section, ) = match.groups()
		
		reference_exists = False
		did_change = False
		
		productgroup_hash = None
		
		match = re.search('projectReferences = \(\n((?:.|\n)+?)\n[ \t]+\);', project_section)
		if not match:
			logging.info("Creating project references...")
			match = re.search('projectDirPath = ".*?";\n', project_section)
			if not match:
				logging.error("Couldn't find project references anchor.")
				return False
			
			did_change = True
			project_section = project_section[:match.end()] + '\t\t\tprojectReferences = (\n\t\t\t);\n' + project_section[match.end():]

		else:
			(refs, ) = match.groups()

			match = re.search('\{\n[ \t]+ProductGroup = ([A-Z0-9]+) \/\* Products \*\/;\n[ \t]+ProjectRef = '+re.escape(pbxfileref_hash), refs)
			if match:
				(productgroup_hash, ) = match.groups()
				logging.info("This product group already exists: "+productgroup_hash)
				reference_exists = True


		if not reference_exists:
			match = re.search('projectReferences = \(\n', project_section)
			
			if not match:
				logging.error("Missing the project references item.")
				return False
			
			productgroup_hash = tthash_base+'3'

			reference_text = '\t\t\t\t{\n\t\t\t\t\tProductGroup = '+productgroup_hash+' /* Products */;\n\t\t\t\t\tProjectRef = '+pbxfileref_hash+' /* '+dep._project_name+'.xcodeproj */;\n\t\t\t\t},\n'
			project_section = project_section[:match.end()] + reference_text + project_section[match.end():]
			did_change = True
			
		if did_change:
			project_data = project_data[:project_start] + project_section + project_data[project_end:]

		logging.info("Done: Created project reference.")
		self.set_project_data(project_data)

		###############################################
		logging.info("")
		logging.info("Step 4.1: Create product group...")

		match = re.search('\/\* Begin PBXGroup section \*\/\n', project_data)
		if not match:
			logging.error("Couldn't find the group section.")
			return False
		
		group_start = match.end()

		lib_hash = None

		match = re.search(re.escape(productgroup_hash)+" \/\* Products \*\/ = \{\n[ \t]+isa = PBXGroup;\n[ \t]+children = \(\n((?:.|\n)+?)\);", project_data)
		if match:
			logging.info("This product group already exists.")
			(children, ) = match.groups()
			match = re.search('([A-Z0-9]+) \/\* '+re.escape(dep_target.product_name())+' \*\/', children)
			if not match:
				logging.error("No product found")
				return False
				# TODO: Add this product.
			else:
				(lib_hash, ) = match.groups()
			
		else:
			lib_hash = tthash_base+'4'

			productgrouptext = "\t\t"+productgroup_hash+" /* Products */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t"+lib_hash+" /* "+dep_target.product_name()+" */,\n\t\t\t);\n\t\t\tname = Products;\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"
			project_data = project_data[:group_start] + productgrouptext + project_data[group_start:]

		logging.info("Done: Created product group: "+lib_hash)
		self.set_project_data(project_data)
		
		###############################################
		logging.info("")
		logging.info("Step 4.2: Add container proxy for target product...")

		containerExists = False
		
		targetproduct_hash = tthash_base+'6'

		match = re.search('\/\* Begin PBXContainerItemProxy section \*\/\n((?:.|\n)+?)\/\* End PBXContainerItemProxy section \*\/', project_data)
		if not match:
			logging.info("\tAdding a PBXContainerItemProxy section...")
			match = re.search('\/\* End PBXBuildFile section \*\/\n', project_data)
			
			if not match:
				logging.error("Couldn't find the PBXBuildFile section.")
				return False
			
			project_data = project_data[:match.end()] + "\n/* Begin PBXContainerItemProxy section */\n\n/* End PBXContainerItemProxy section */\n" + project_data[match.end():]
		else:
			(subtext, ) = match.groups()
			match = re.search(re.escape(targetproduct_hash), subtext)
			if match:
				logging.info("This container proxy already exists.")
				containerExists = True

		self.set_project_data(project_data)
		
		if not containerExists:
			match = re.search('\/\* Begin PBXContainerItemProxy section \*\/\n', project_data)

			pbxcontaineritemproxy = "\t\t"+targetproduct_hash+" /* PBXContainerItemProxy */ = {\n\t\t\tisa = PBXContainerItemProxy;\n\t\t\tcontainerPortal = "+pbxfileref_hash+" /* "+dep._project_name+".xcodeproj */;\n\t\t\tproxyType = 2;\n\t\t\tremoteGlobalIDString = "+dep_target.guid()+";\n\t\t\tremoteInfo = "+dep._project_name+";\n\t\t};\n"
			project_data = project_data[:match.end()] + pbxcontaineritemproxy + project_data[match.end():]

		logging.info("Done: Added target container proxy.")
		self.set_project_data(project_data)


		###############################################
		# This code seems to break the xcode project but doesn't seem completely crucial.
		# Gr.

		# logging.info("")
		# logging.info("Step 4.3: Create reference proxy...")
		# 
		# referenceExists = False
		# 
		# match = re.search('\/\* Begin PBXReferenceProxy section \*\/\n((?:.|\n)+?)\/\* End PBXReferenceProxy section \*\/', project_data)
		# if not match:
		# 	logging.info("\tAdding a PBXReferenceProxy section...")
		# 	match = re.search('\/\* End PBXProject section \*\/\n', project_data)
		# 	
		# 	if not match:
		# 		logging.error("Couldn't find the PBXProject section.")
		# 		return False
		# 	
		# 	project_data = project_data[:match.end()] + "\n/* Begin PBXReferenceProxy section */\n\n/* End PBXReferenceProxy section */\n" + project_data[match.end():]
		# else:
		# 	(subtext, ) = match.groups()
		# 	match = re.search(re.escape(lib_hash), subtext)
		# 	if match:
		# 		logging.info("This reference proxy already exists.")
		# 		referenceExists = True
		# 
		# self.set_project_data(project_data)
		# 
		# if not referenceExists:
		# 	match = re.search('\/\* Begin PBXReferenceProxy section \*\/\n', project_data)
		# 
		# 	referenceproxytext = "\t\t"+lib_hash+" /* "+dep_target.product_name()+" */ = {\n\t\t\tisa = PBXReferenceProxy;\n\t\t\tfileType = archive.ar;\n\t\t\tpath = \""+dep_target.product_name()+"\";\n\t\t\tremoteRef = "+targetproduct_hash+" /* PBXContainerItemProxy */;\n\t\t\tsourceTree = BUILT_PRODUCTS_DIR;\n\t\t};\n"
		# 	project_data = project_data[:match.end()] + referenceproxytext + project_data[match.end():]
		# 
		# logging.info("Done: Created reference proxy.")
		# self.set_project_data(project_data)


		###############################################
		logging.info("")
		logging.info("Step 5: Add target file...")

		libfile_hash = self.add_buildfile(dep_target.product_name(), lib_hash, tthash_base+'5')
		project_data = self.get_project_data()

		logging.info("Done: Added target file.")
		

		###############################################
		logging.info("")
		logging.info("Step 6: Add frameworks...")

		self.add_file_to_frameworks_phase(dep_target.product_name(), libfile_hash)
		project_data = self.get_project_data()

		logging.info("Done: Adding module.")

		self.set_project_data(project_data, flush = True)

		return True
