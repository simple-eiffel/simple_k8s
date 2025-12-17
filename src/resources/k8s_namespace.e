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

	parse_json (a_obj: like api.json.json_object_typeref)
			-- Parse JSON object into namespace fields.
		require
			obj_attached: a_obj /= Void
		local
			l_metadata: like api.json.json_object_typeref
			l_status: like api.json.json_object_typeref
			l_key: STRING_32
			l_val: STRING_32
		do
			-- Initialize defaults
			name := "unknown"
			phase := "Active"
			create labels.make (10)
			create annotations.make (10)

			-- Parse metadata
			if attached a_obj.object_item ("metadata") as meta then
				l_metadata := meta
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

			-- Parse status
			if attached a_obj.object_item ("status") as st then
				l_status := st
				if attached l_status.string_item ("phase") as p then
					phase := p.to_string_8
				end
			end
		end

invariant
	name_not_empty: not name.is_empty
	phase_not_empty: not phase.is_empty

end