note
	description: "Kubernetes ConfigMap resource representation"
	author: "Larry Rix"

class
	K8S_CONFIGMAP

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make (a_name, a_namespace: STRING)
			-- Create with name and namespace.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
		do
			create api
			name := a_name
			namespace := a_namespace
			create labels.make (10)
			create annotations.make (10)
			create data.make (10)
			create binary_data.make (5)
		ensure
			name_set: name.same_string (a_name)
			namespace_set: namespace.same_string (a_namespace)
		end

	make_from_json (a_json: STRING)
			-- Parse configmap from JSON response.
		require
			json_not_empty: not a_json.is_empty
		do
			create api
			if attached api.parse_json (a_json) as l_root then
				parse_json (l_root.as_object)
			else
				make ("unknown", "default")
				has_parse_error := True
			end
		end

feature -- Access

	api: FOUNDATION_API
			-- Foundation API.

	name: STRING
			-- ConfigMap name.

	namespace: STRING
			-- ConfigMap namespace.

	uid: detachable STRING
			-- Unique identifier.

	resource_version: detachable STRING
			-- Resource version for optimistic locking.

	labels: HASH_TABLE [STRING, STRING]
			-- Labels.

	annotations: HASH_TABLE [STRING, STRING]
			-- Annotations.

	data: HASH_TABLE [STRING, STRING]
			-- String data (key-value pairs).

	binary_data: HASH_TABLE [STRING, STRING]
			-- Binary data (base64 encoded).

	creation_timestamp: detachable STRING
			-- When configmap was created.

	has_parse_error: BOOLEAN
			-- Did parsing fail?

feature -- Data Access

	item (a_key: STRING): detachable STRING
			-- Get data value for key.
		require
			key_not_empty: not a_key.is_empty
		do
			Result := data.item (a_key)
		end

	has_key (a_key: STRING): BOOLEAN
			-- Does data contain key?
		require
			key_not_empty: not a_key.is_empty
		do
			Result := data.has (a_key)
		end

	keys: ARRAY [STRING]
			-- All data keys.
		local
			l_list: ARRAYED_LIST [STRING]
		do
			create l_list.make (data.count)
			from data.start until data.after loop
				l_list.extend (data.key_for_iteration)
				data.forth
			end
			Result := l_list.to_array
		end

feature {NONE} -- Parsing

	parse_json (a_obj: like api.new_json_object)
			-- Parse JSON object into configmap fields.
		require
			obj_attached: a_obj /= Void
		local
			l_metadata: detachable like api.new_json_object
		do
			-- Initialize defaults
			name := "unknown"
			namespace := "default"
			create labels.make (10)
			create annotations.make (10)
			create data.make (10)
			create binary_data.make (5)

			-- Parse metadata
			l_metadata := a_obj.object_item ("metadata")
			if attached l_metadata then
				if attached l_metadata.string_item ("name") as n then
					name := n.to_string_8
				end
				if attached l_metadata.string_item ("namespace") as ns then
					namespace := ns.to_string_8
				end
				if attached l_metadata.string_item ("uid") as u then
					uid := u.to_string_8
				end
				if attached l_metadata.string_item ("resourceVersion") as rv then
					resource_version := rv.to_string_8
				end
				if attached l_metadata.string_item ("creationTimestamp") as ts then
					creation_timestamp := ts.to_string_8
				end
				-- Parse labels
				parse_string_map (l_metadata.object_item ("labels"), labels)
				-- Parse annotations
				parse_string_map (l_metadata.object_item ("annotations"), annotations)
			end

			-- Parse data
			parse_string_map (a_obj.object_item ("data"), data)

			-- Parse binaryData
			parse_string_map (a_obj.object_item ("binaryData"), binary_data)
		end

	parse_string_map (a_obj: detachable like api.new_json_object; a_map: HASH_TABLE [STRING, STRING])
			-- Parse JSON object into string map.
		local
			l_keys: ARRAY [STRING_32]
			i: INTEGER
			l_key: STRING_32
		do
			if attached a_obj then
				l_keys := a_obj.keys
				from i := l_keys.lower until i > l_keys.upper loop
					l_key := l_keys [i]
					if attached a_obj.string_item (l_key) as l_val then
						a_map.put (l_val.to_string_8, l_key.to_string_8)
					end
					i := i + 1
				end
			end
		end

invariant
	name_not_empty: not name.is_empty
	namespace_not_empty: not namespace.is_empty

end