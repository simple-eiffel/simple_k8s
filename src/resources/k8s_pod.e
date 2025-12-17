note
	description: "Kubernetes Pod resource representation"
	author: "Larry Rix"

class
	K8S_POD

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
			phase := "Unknown"
			create labels.make (10)
			create annotations.make (10)
			create container_statuses.make (5)
		ensure
			name_set: name.same_string (a_name)
			namespace_set: namespace.same_string (a_namespace)
		end

	make_from_json (a_json: STRING)
			-- Parse pod from JSON response.
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
			-- Pod name.

	namespace: STRING
			-- Pod namespace.

	uid: detachable STRING
			-- Unique identifier.

	resource_version: detachable STRING
			-- Resource version for optimistic concurrency.

	creation_timestamp: detachable STRING
			-- When the pod was created.

	phase: STRING
			-- Pod phase: Pending, Running, Succeeded, Failed, Unknown.

	pod_ip: detachable STRING
			-- IP address assigned to the pod.

	host_ip: detachable STRING
			-- IP address of the node hosting the pod.

	node_name: detachable STRING
			-- Name of the node running the pod.

	image: detachable STRING
			-- Primary container image.

	restart_count: INTEGER
			-- Total restart count across all containers.

	labels: HASH_TABLE [STRING, STRING]
			-- Pod labels.

	annotations: HASH_TABLE [STRING, STRING]
			-- Pod annotations.

	container_statuses: ARRAYED_LIST [TUPLE [name: STRING; ready: BOOLEAN; restart_count: INTEGER; state: STRING]]
			-- Container status information.

feature -- Status

	is_running: BOOLEAN
		do
			Result := phase.same_string ("Running")
		end

	is_pending: BOOLEAN
		do
			Result := phase.same_string ("Pending")
		end

	is_succeeded: BOOLEAN
		do
			Result := phase.same_string ("Succeeded")
		end

	is_failed: BOOLEAN
		do
			Result := phase.same_string ("Failed")
		end

	is_ready: BOOLEAN
		do
			Result := is_running and then all_containers_ready
		end

	has_parse_error: BOOLEAN

feature -- Output

	describe: STRING
			-- kubectl describe-like output.
		do
			create Result.make (500)
			Result.append ("Name: " + name + "%N")
			Result.append ("Namespace: " + namespace + "%N")
			if attached uid as u then
				Result.append ("UID: " + u + "%N")
			end
			Result.append ("Status: " + phase + "%N")
			if attached pod_ip as ip then
				Result.append ("IP: " + ip + "%N")
			end
			if attached node_name as node then
				Result.append ("Node: " + node + "%N")
			end
			if attached image as img then
				Result.append ("Image: " + img + "%N")
			end
			Result.append ("Restart Count: " + restart_count.out + "%N")
			if not labels.is_empty then
				Result.append ("Labels:%N")
				from labels.start until labels.after loop
					Result.append ("  " + labels.key_for_iteration + "=" + labels.item_for_iteration + "%N")
					labels.forth
				end
			end
			if not container_statuses.is_empty then
				Result.append ("Containers:%N")
				from container_statuses.start until container_statuses.after loop
					Result.append ("  " + container_statuses.item.name + ": " + container_statuses.item.state)
					if container_statuses.item.ready then
						Result.append (" (Ready)")
					end
					Result.append ("%N")
					container_statuses.forth
				end
			end
		end

feature {NONE} -- Implementation

	all_containers_ready: BOOLEAN
		do
			Result := True
			from container_statuses.start until container_statuses.after or not Result loop
				Result := container_statuses.item.ready
				container_statuses.forth
			end
		end

	parse_json (a_root: like api.new_json_object)
			-- Parse JSON into pod attributes.
		local
			l_metadata, l_spec, l_status: detachable like api.new_json_object
			l_containers: detachable like api.new_json_array
		do
			name := "unknown"
			namespace := "default"
			phase := "Unknown"
			create labels.make (10)
			create annotations.make (10)
			create container_statuses.make (5)

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
				l_containers := l_spec.array_item ("containers")
				if attached l_containers and then l_containers.count > 0 then
					if attached l_containers.object_item (1) as first_container then
						if attached first_container.string_item ("image") as img then
							image := img.to_string_8
						end
					end
				end
				if attached l_spec.string_item ("nodeName") as node then
					node_name := node.to_string_8
				end
			end

			l_status := a_root.object_item ("status")
			if attached l_status then
				if attached l_status.string_item ("phase") as p then
					phase := p.to_string_8
				end
				if attached l_status.string_item ("podIP") as ip then
					pod_ip := ip.to_string_8
				end
				if attached l_status.string_item ("hostIP") as hip then
					host_ip := hip.to_string_8
				end
				parse_container_statuses (l_status.array_item ("containerStatuses"))
			end
		end

	parse_string_map (a_obj: detachable like api.new_json_object; a_map: HASH_TABLE [STRING, STRING])
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

	parse_container_statuses (a_arr: detachable like api.new_json_array)
		local
			i: INTEGER
			l_name, l_state: STRING
			l_ready: BOOLEAN
			l_restarts: INTEGER
		do
			if attached a_arr then
				from i := 1 until i > a_arr.count loop
					if attached a_arr.object_item (i) as cs then
						l_name := ""
						l_state := "unknown"
						l_ready := False
						l_restarts := 0
						if attached cs.string_item ("name") as n then
							l_name := n.to_string_8
						end
						l_ready := cs.boolean_item ("ready")
						l_restarts := cs.integer_item ("restartCount").to_integer_32
						restart_count := restart_count + l_restarts
						if attached cs.object_item ("state") as state then
							if state.has_key ("running") then
								l_state := "Running"
							elseif attached state.object_item ("waiting") as w then
								l_state := "Waiting"
								if attached w.string_item ("reason") as reason then
									l_state := reason.to_string_8
								end
							elseif attached state.object_item ("terminated") as t then
								l_state := "Terminated"
								if attached t.string_item ("reason") as reason then
									l_state := reason.to_string_8
								end
							end
						end
						container_statuses.extend ([l_name, l_ready, l_restarts, l_state])
					end
					i := i + 1
				end
			end
		end

invariant
	api_not_void: api /= Void
	name_not_void: name /= Void
	namespace_not_void: namespace /= Void
	phase_not_void: phase /= Void

end
