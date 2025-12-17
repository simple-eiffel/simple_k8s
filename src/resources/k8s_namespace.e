note
	description: "Kubernetes Namespace resource representation"
	author: "Larry Rix"

class
	K8S_NAMESPACE

create
	make,
	make_from_json

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create with name.
		require
			name_not_empty: not a_name.is_empty
		do
			create api
			name := a_name
			phase := "Active"
			create labels.make (10)
			create annotations.make (10)
		ensure
			name_set: name.same_string (a_name)
		end

	make_from_json (a_json: STRING)
			-- Parse namespace from JSON response.
		require
			json_not_empty: not a_json.is_empty
		do
			create api
			if attached api.parse_json (a_json) as l_root then
				parse_json (l_root.as_object)
			else
				make ("unknown")
				has_parse_error := True
			end
		end

feature -- Access

	api: FOUNDATION_API
			-- Foundation API.

	name: STRING
			-- Namespace name.

	uid: detachable STRING
			-- Unique identifier.

	resource_version: detachable STRING
			-- Resource version for optimistic locking.

	phase: STRING
			-- Namespace phase (Active, Terminating).

	labels: HASH_TABLE [STRING, STRING]
			-- Labels.

	annotations: HASH_TABLE [STRING, STRING]
			-- Annotations.

	creation_timestamp: detachable STRING
			-- When namespace was created.

	has_parse_error: BOOLEAN
			-- Did parsing fail?

feature -- Status

	is_active: BOOLEAN
			-- Is namespace active?
		do
			Result := phase.same_string ("Active")
		end

	is_terminating: BOOLEAN
			-- Is namespace being deleted?
		do
			Result := phase.same_string ("Terminating")
		end

feature {NONE} -- Parsing

	parse_json (a_obj: like api.new_json_object)
			-- Parse JSON object into namespace fields.
		require
			obj_attached: a_obj /= Void
		local
			l_metadata: detachable like api.new_json_object
			l_status: detachable like api.new_json_object
		do
			-- Initialize defaults
			name := "unknown"
			phase := "Active"
			create labels.make (10)
			create annotations.make (10)

			-- Parse metadata
			l_metadata := a_obj.object_item ("metadata")
			if attached l_metadata then
				if attached l_metadata.string_item ("name") as n then
					name := n.to_string_8
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

			-- Parse status
			l_status := a_obj.object_item ("status")
			if attached l_status then
				if attached l_status.string_item ("phase") as p then
					phase := p.to_string_8
				end
			end
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
	phase_not_empty: not phase.is_empty

end