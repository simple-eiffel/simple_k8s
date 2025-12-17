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

	parse_json (a_obj: like api.json.json_object_typeref)
			-- Parse JSON object into configmap fields.
		require
			obj_attached: a_obj /= Void
		local
			l_metadata: like api.json.json_object_typeref
			l_key: STRING_32
			l_val: STRING_32
		do
			-- Initialize defaults
			name := "unknown"
			namespace := "default"
			create labels.make (10)
			create annotations.make (10)
			create data.make (10)
			create binary_data.make (5)

			-- Parse metadata
			if attached a_obj.object_item ("metadata") as meta then
				l_metadata := meta
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
				if attached l_metadata.object_item ("labels") as lbl_obj then
					from lbl_obj.start until lbl_obj.after loop
						l_key := lbl_obj.key_for_iteration
						if attached lbl_obj.item_for_iteration.as_string as lv then
							l_val := lv
							labels.put (l_val.to_string_8, l_key.to_string_8)
						end
						lbl_obj.forth
					end
				end
				-- Parse annotations
				if attached l_metadata.object_item ("annotations") as ann_obj then
					from ann_obj.start until ann_obj.after loop
						l_key := ann_obj.key_for_iteration
						if attached ann_obj.item_for_iteration.as_string as av then
							l_val := av
							annotations.put (l_val.to_string_8, l_key.to_string_8)
						end
						ann_obj.forth
					end
				end
			end

			-- Parse data
			if attached a_obj.object_item ("data") as data_obj then
				from data_obj.start until data_obj.after loop
					l_key := data_obj.key_for_iteration
					if attached data_obj.item_for_iteration.as_string as dv then
						l_val := dv
						data.put (l_val.to_string_8, l_key.to_string_8)
					end
					data_obj.forth
				end
			end

			-- Parse binaryData
			if attached a_obj.object_item ("binaryData") as bin_obj then
				from bin_obj.start until bin_obj.after loop
					l_key := bin_obj.key_for_iteration
					if attached bin_obj.item_for_iteration.as_string as bv then
						l_val := bv
						binary_data.put (l_val.to_string_8, l_key.to_string_8)
					end
					bin_obj.forth
				end
			end
		end

invariant
	name_not_empty: not name.is_empty
	namespace_not_empty: not namespace.is_empty

end