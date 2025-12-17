note
	description: "Kubernetes Deployment resource representation"
	author: "Larry Rix"

class
	K8S_DEPLOYMENT

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
			create selector.make (10)
		ensure
			name_set: name.same_string (a_name)
			namespace_set: namespace.same_string (a_namespace)
		end

	make_from_json (a_json: STRING)
			-- Parse deployment from JSON response.
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

	name: STRING

	namespace: STRING

	uid: detachable STRING

	resource_version: detachable STRING

	creation_timestamp: detachable STRING

	replicas: INTEGER

	ready_replicas: INTEGER

	available_replicas: INTEGER

	updated_replicas: INTEGER

	unavailable_replicas: INTEGER

	observed_generation: INTEGER

	image: detachable STRING

	strategy: detachable STRING

	labels: HASH_TABLE [STRING, STRING]

	annotations: HASH_TABLE [STRING, STRING]

	selector: HASH_TABLE [STRING, STRING]

feature -- Status

	is_available: BOOLEAN
		do
			Result := available_replicas >= replicas and replicas > 0
		end

	is_progressing: BOOLEAN
		do
			Result := updated_replicas < replicas or unavailable_replicas > 0
		end

	is_complete: BOOLEAN
		do
			Result := ready_replicas = replicas and available_replicas = replicas and updated_replicas = replicas
		end

	has_parse_error: BOOLEAN

feature -- Output

	describe: STRING
		do
			create Result.make (500)
			Result.append ("Name: " + name + "%N")
			Result.append ("Namespace: " + namespace + "%N")
			if attached uid as u then
				Result.append ("UID: " + u + "%N")
			end
			Result.append ("Replicas: " + replicas.out)
			Result.append (" desired | " + ready_replicas.out + " ready")
			Result.append (" | " + available_replicas.out + " available")
			Result.append (" | " + updated_replicas.out + " updated%N")
			if attached strategy as s then
				Result.append ("Strategy: " + s + "%N")
			end
			if attached image as img then
				Result.append ("Image: " + img + "%N")
			end
			if not labels.is_empty then
				Result.append ("Labels:%N")
				from labels.start until labels.after loop
					Result.append ("  " + labels.key_for_iteration + "=" + labels.item_for_iteration + "%N")
					labels.forth
				end
			end
			if not selector.is_empty then
				Result.append ("Selector:%N")
				from selector.start until selector.after loop
					Result.append ("  " + selector.key_for_iteration + "=" + selector.item_for_iteration + "%N")
					selector.forth
				end
			end
		end

feature {NONE} -- Implementation

	parse_json (a_root: like api.new_json_object)
		local
			l_metadata, l_spec, l_status: detachable like api.new_json_object
			l_template, l_match_labels: detachable like api.new_json_object
			l_containers: detachable like api.new_json_array
		do
			name := "unknown"
			namespace := "default"
			create labels.make (10)
			create annotations.make (10)
			create selector.make (10)

			l_metadata := a_root.object_item ("metadata")
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
				parse_string_map (l_metadata.object_item ("labels"), labels)
				parse_string_map (l_metadata.object_item ("annotations"), annotations)
			end

			l_spec := a_root.object_item ("spec")
			if attached l_spec then
				replicas := l_spec.integer_item ("replicas").to_integer_32
				if attached l_spec.object_item ("strategy") as strat then
					if attached strat.string_item ("type") as t then
						strategy := t.to_string_8
					end
				end
				if attached l_spec.object_item ("selector") as sel then
					l_match_labels := sel.object_item ("matchLabels")
					parse_string_map (l_match_labels, selector)
				end
				l_template := l_spec.object_item ("template")
				if attached l_template then
					if attached l_template.object_item ("spec") as tspec then
						l_containers := tspec.array_item ("containers")
						if attached l_containers and then l_containers.count > 0 then
							if attached l_containers.object_at (1) as first_container then
								if attached first_container.string_item ("image") as img then
									image := img.to_string_8
								end
							end
						end
					end
				end
			end

			l_status := a_root.object_item ("status")
			if attached l_status then
				replicas := l_status.integer_item ("replicas").to_integer_32
				ready_replicas := l_status.integer_item ("readyReplicas").to_integer_32
				available_replicas := l_status.integer_item ("availableReplicas").to_integer_32
				updated_replicas := l_status.integer_item ("updatedReplicas").to_integer_32
				unavailable_replicas := l_status.integer_item ("unavailableReplicas").to_integer_32
				observed_generation := l_status.integer_item ("observedGeneration").to_integer_32
			end
		end

	parse_string_map (a_obj: detachable like api.new_json_object; a_map: HASH_TABLE [STRING, STRING])
		do
			if attached a_obj then
				across a_obj.keys as k loop
					if attached a_obj.string_item (k.item) as val then
						a_map.put (val.to_string_8, k.item.to_string_8)
					end
				end
			end
		end

invariant
	api_not_void: api /= Void
	name_not_void: name /= Void
	namespace_not_void: namespace /= Void

end
