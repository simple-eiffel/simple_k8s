note
	description: "Kubernetes Secret resource representation"
	author: "Larry Rix"

class
	K8S_SECRET

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
			create json.make
			create base64.make
			name := a_name
			namespace := a_namespace
			secret_type := "Opaque"
			create labels.make (10)
			create annotations.make (10)
			create data.make (10)
			create string_data.make (10)
		ensure
			name_set: name.same_string (a_name)
			namespace_set: namespace.same_string (a_namespace)
		end

	make_from_json (a_json: STRING)
			-- Parse secret from JSON response.
		require
			json_not_empty: not a_json.is_empty
		do
			create json.make
			create base64.make
			if attached json.parse_object (a_json) as l_root then
				parse_json (l_root)
			else
				make ("unknown", "default")
				has_parse_error := True
			end
		end

feature -- Access

	json: SIMPLE_JSON_QUICK
			-- JSON parser.

	base64: SIMPLE_BASE64
			-- Base64 decoder.

	name: STRING
			-- Secret name.

	namespace: STRING
			-- Secret namespace.

	uid: detachable STRING
			-- Unique identifier.

	resource_version: detachable STRING
			-- Resource version for optimistic locking.

	secret_type: STRING
			-- Secret type (Opaque, kubernetes.io/tls, etc).

	labels: HASH_TABLE [STRING, STRING]
			-- Labels.

	annotations: HASH_TABLE [STRING, STRING]
			-- Annotations.

	data: HASH_TABLE [STRING, STRING]
			-- Base64-encoded data.

	string_data: HASH_TABLE [STRING, STRING]
			-- Plain string data.

	creation_timestamp: detachable STRING
			-- When secret was created.

	has_parse_error: BOOLEAN
			-- Did parsing fail?

feature -- Data Access

	item (a_key: STRING): detachable STRING
			-- Get decoded data value for key.
		require
			key_not_empty: not a_key.is_empty
		do
			if attached data.item (a_key) as b64 then
				Result := base64.decode (b64)
			elseif attached string_data.item (a_key) as plain then
				Result := plain
			end
		end

	has_key (a_key: STRING): BOOLEAN
			-- Does data contain key?
		require
			key_not_empty: not a_key.is_empty
		do
			Result := data.has (a_key) or string_data.has (a_key)
		end

	keys: ARRAY [STRING]
			-- All data keys.
		local
			l_list: ARRAYED_LIST [STRING]
		do
			create l_list.make (data.count + string_data.count)
			from data.start until data.after loop
				l_list.extend (data.key_for_iteration)
				data.forth
			end
			from string_data.start until string_data.after loop
				l_list.extend (string_data.key_for_iteration)
				string_data.forth
			end
			Result := l_list.to_array
		end

feature -- Type Queries

	is_opaque: BOOLEAN
			-- Is this an opaque secret?
		do
			Result := secret_type.same_string ("Opaque")
		end

	is_tls: BOOLEAN
			-- Is this a TLS secret?
		do
			Result := secret_type.same_string ("kubernetes.io/tls")
		end

	is_docker_config: BOOLEAN
			-- Is this a Docker config secret?
		do
			Result := secret_type.same_string ("kubernetes.io/dockerconfigjson")
		end

	is_service_account_token: BOOLEAN
			-- Is this a service account token?
		do
			Result := secret_type.same_string ("kubernetes.io/service-account-token")
		end

feature {NONE} -- Parsing

	parse_json (a_obj: SIMPLE_JSON_OBJECT)
			-- Parse JSON object into secret fields.
		require
			obj_attached: a_obj /= Void
		local
			l_metadata: detachable SIMPLE_JSON_OBJECT
		do
			-- Initialize defaults
			name := "unknown"
			namespace := "default"
			secret_type := "Opaque"
			create labels.make (10)
			create annotations.make (10)
			create data.make (10)
			create string_data.make (10)

			-- Parse type
			if attached a_obj.string_item ("type") as t then
				secret_type := t.to_string_8
			end

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

			-- Parse data (base64)
			parse_string_map (a_obj.object_item ("data"), data)

			-- Parse stringData
			parse_string_map (a_obj.object_item ("stringData"), string_data)
		end

	parse_string_map (a_obj: detachable SIMPLE_JSON_OBJECT; a_map: HASH_TABLE [STRING, STRING])
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
	type_not_empty: not secret_type.is_empty

end