note
	description: "Pod specification with fluent builder pattern for Kubernetes pod creation"
	author: "Larry Rix"
	DBC: "Preconditions validate all configurations before API submission"

class
	POD_SPEC

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty pod specification.
		do
			name := ""
			image := ""
			namespace := "default"
			restart_policy := "Always"
			create environment.make (10)
			create ports.make (5)
			create volumes.make (5)
			create labels.make (10)
			create annotations.make (10)
		ensure
			default_namespace: namespace.same_string ("default")
			default_restart: restart_policy.same_string ("Always")
		end

feature -- Required Configuration

	name: STRING assign set_name_direct
			-- Pod name (must be valid DNS subdomain).

	image: STRING assign set_image_direct
			-- Container image (e.g., "nginx:alpine").

feature -- Optional Configuration

	namespace: STRING
			-- Target namespace (default: "default").

	command: detachable ARRAY [STRING]
			-- Override container entrypoint.

	args: detachable ARRAY [STRING]
			-- Arguments to the entrypoint.

	environment: HASH_TABLE [STRING, STRING]
			-- Environment variables (key -> value).

	ports: ARRAYED_LIST [TUPLE [name: STRING; port: INTEGER]]
			-- Container ports to expose.

	volumes: ARRAYED_LIST [TUPLE [name: STRING; mount_path: STRING; source: STRING]]
			-- Volume mounts.

	labels: HASH_TABLE [STRING, STRING]
			-- Pod labels for selection.

	annotations: HASH_TABLE [STRING, STRING]
			-- Pod annotations for metadata.

	restart_policy: STRING
			-- "Always", "OnFailure", or "Never".

feature -- Resource Limits

	cpu_request: detachable STRING
			-- CPU request (e.g., "100m" = 0.1 CPU).

	cpu_limit: detachable STRING
			-- CPU limit (e.g., "500m" = 0.5 CPU).

	memory_request: detachable STRING
			-- Memory request (e.g., "128Mi").

	memory_limit: detachable STRING
			-- Memory limit (e.g., "512Mi").

feature -- Fluent Builder: Required

	set_name (a_name: STRING): like Current
			-- Set pod name (fluent).
		require
			valid_name: is_valid_k8s_name (a_name)
		do
			name := a_name
			Result := Current
		ensure
			name_set: name.same_string (a_name)
		end

	set_image (a_image: STRING): like Current
			-- Set container image (fluent).
		require
			not_empty: not a_image.is_empty
		do
			image := a_image
			Result := Current
		ensure
			image_set: image.same_string (a_image)
		end

feature -- Fluent Builder: Optional

	set_namespace (a_namespace: STRING): like Current
			-- Set target namespace (fluent).
		require
			not_empty: not a_namespace.is_empty
		do
			namespace := a_namespace
			Result := Current
		ensure
			namespace_set: namespace.same_string (a_namespace)
		end

	set_command (a_command: ARRAY [STRING]): like Current
			-- Set container command override (fluent).
		do
			command := a_command
			Result := Current
		ensure
			command_set: command = a_command
		end

	set_args (a_args: ARRAY [STRING]): like Current
			-- Set container arguments (fluent).
		do
			args := a_args
			Result := Current
		ensure
			args_set: args = a_args
		end

	set_restart_policy (a_policy: STRING): like Current
			-- Set restart policy (fluent).
		require
			valid_policy: a_policy.same_string ("Always") or
			              a_policy.same_string ("OnFailure") or
			              a_policy.same_string ("Never")
		do
			restart_policy := a_policy
			Result := Current
		ensure
			policy_set: restart_policy.same_string (a_policy)
		end

	add_env (a_key, a_value: STRING): like Current
			-- Add environment variable (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			environment.force (a_value, a_key)
			Result := Current
		ensure
			env_added: environment.has (a_key)
		end

	add_port (a_name: STRING; a_port: INTEGER): like Current
			-- Add container port (fluent).
		require
			valid_port: a_port > 0 and a_port <= 65535
		do
			ports.extend ([a_name, a_port])
			Result := Current
		ensure
			port_added: ports.count = old ports.count + 1
		end

	add_volume (a_name, a_mount_path, a_source: STRING): like Current
			-- Add volume mount (fluent).
		require
			name_not_empty: not a_name.is_empty
			path_not_empty: not a_mount_path.is_empty
		do
			volumes.extend ([a_name, a_mount_path, a_source])
			Result := Current
		ensure
			volume_added: volumes.count = old volumes.count + 1
		end

	add_label (a_key, a_value: STRING): like Current
			-- Add pod label (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			labels.force (a_value, a_key)
			Result := Current
		ensure
			label_added: labels.has (a_key)
		end

	add_annotation (a_key, a_value: STRING): like Current
			-- Add pod annotation (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			annotations.force (a_value, a_key)
			Result := Current
		ensure
			annotation_added: annotations.has (a_key)
		end

	set_resources (a_cpu_req, a_cpu_lim, a_mem_req, a_mem_lim: STRING): like Current
			-- Set all resource limits (fluent).
		do
			cpu_request := a_cpu_req
			cpu_limit := a_cpu_lim
			memory_request := a_mem_req
			memory_limit := a_mem_lim
			Result := Current
		end

	set_cpu (a_request, a_limit: STRING): like Current
			-- Set CPU resources (fluent).
		do
			cpu_request := a_request
			cpu_limit := a_limit
			Result := Current
		end

	set_memory (a_request, a_limit: STRING): like Current
			-- Set memory resources (fluent).
		do
			memory_request := a_request
			memory_limit := a_limit
			Result := Current
		end

feature -- Direct Setters (non-fluent, for assign)

	set_name_direct (a_name: STRING)
			-- Set pod name directly.
		require
			valid_name: is_valid_k8s_name (a_name)
		do
			name := a_name
		ensure
			name_set: name.same_string (a_name)
		end

	set_image_direct (a_image: STRING)
			-- Set container image directly.
		require
			not_empty: not a_image.is_empty
		do
			image := a_image
		ensure
			image_set: image.same_string (a_image)
		end

feature -- Validation

	is_valid: BOOLEAN
			-- Is specification valid for submission to K8s API?
		do
			Result := not name.is_empty and not image.is_empty
		ensure
			definition: Result = (not name.is_empty and not image.is_empty)
		end

	is_valid_k8s_name (a_name: STRING): BOOLEAN
			-- Is `a_name' a valid Kubernetes resource name?
			-- Must be lowercase, alphanumeric with hyphens, max 253 chars.
		local
			i: INTEGER
			c: CHARACTER
		do
			if not a_name.is_empty and a_name.count <= 253 then
				Result := True
				from i := 1 until i > a_name.count or not Result loop
					c := a_name.item (i)
					Result := (c >= 'a' and c <= 'z') or
					          (c >= '0' and c <= '9') or
					          c = '-'
					i := i + 1
				end
				-- Cannot start or end with hyphen
				if Result then
					Result := a_name.item (1) /= '-' and a_name.item (a_name.count) /= '-'
				end
			end
		end

feature -- Output

	to_json: STRING
			-- Generate JSON for Kubernetes API POST request.
		require
			valid: is_valid
		local
			l_result: STRING
		do
			create l_result.make (1024)
			l_result.append ("{")

			-- API Version and Kind
			l_result.append ("%"apiVersion%":%"v1%",")
			l_result.append ("%"kind%":%"Pod%",")

			-- Metadata
			l_result.append ("%"metadata%":{")
			l_result.append ("%"name%":%"" + name + "%"")
			if not namespace.same_string ("default") then
				l_result.append (",%"namespace%":%"" + namespace + "%"")
			end
			if not labels.is_empty then
				l_result.append (",%"labels%":{")
				append_string_map (l_result, labels)
				l_result.append ("}")
			end
			if not annotations.is_empty then
				l_result.append (",%"annotations%":{")
				append_string_map (l_result, annotations)
				l_result.append ("}")
			end
			l_result.append ("},")

			-- Spec
			l_result.append ("%"spec%":{")
			l_result.append ("%"restartPolicy%":%"" + restart_policy + "%",")

			-- Containers (single container for now)
			l_result.append ("%"containers%":[{")
			l_result.append ("%"name%":%"" + name + "%",")
			l_result.append ("%"image%":%"" + image + "%"")

			-- Command
			if attached command as cmd and then cmd.count > 0 then
				l_result.append (",%"command%":[")
				append_string_array (l_result, cmd)
				l_result.append ("]")
			end

			-- Args
			if attached args as a and then a.count > 0 then
				l_result.append (",%"args%":[")
				append_string_array (l_result, a)
				l_result.append ("]")
			end

			-- Ports
			if not ports.is_empty then
				l_result.append (",%"ports%":[")
				append_ports (l_result)
				l_result.append ("]")
			end

			-- Environment
			if not environment.is_empty then
				l_result.append (",%"env%":[")
				append_env_vars (l_result)
				l_result.append ("]")
			end

			-- Resources
			if has_resources then
				l_result.append (",%"resources%":{")
				append_resources (l_result)
				l_result.append ("}")
			end

			-- Volume mounts
			if not volumes.is_empty then
				l_result.append (",%"volumeMounts%":[")
				append_volume_mounts (l_result)
				l_result.append ("]")
			end

			l_result.append ("}]")  -- Close containers array

			-- Volumes
			if not volumes.is_empty then
				l_result.append (",%"volumes%":[")
				append_volumes (l_result)
				l_result.append ("]")
			end

			l_result.append ("}")  -- Close spec
			l_result.append ("}")  -- Close root

			Result := l_result
		ensure
			result_not_empty: not Result.is_empty
		end

feature {NONE} -- JSON Helpers

	has_resources: BOOLEAN
			-- Are any resource limits set?
		do
			Result := cpu_request /= Void or cpu_limit /= Void or
			          memory_request /= Void or memory_limit /= Void
		end

	append_string_map (a_result: STRING; a_map: HASH_TABLE [STRING, STRING])
			-- Append map as JSON key-value pairs.
		local
			l_first: BOOLEAN
		do
			l_first := True
			from a_map.start until a_map.after loop
				if not l_first then
					a_result.append (",")
				end
				a_result.append ("%"" + a_map.key_for_iteration + "%":%"" + escape_json (a_map.item_for_iteration) + "%"")
				l_first := False
				a_map.forth
			end
		end

	append_string_array (a_result: STRING; a_array: ARRAY [STRING])
			-- Append string array as JSON.
		local
			i: INTEGER
		do
			from i := a_array.lower until i > a_array.upper loop
				if i > a_array.lower then
					a_result.append (",")
				end
				a_result.append ("%"" + escape_json (a_array [i]) + "%"")
				i := i + 1
			end
		end

	append_ports (a_result: STRING)
			-- Append container ports as JSON.
		local
			l_first: BOOLEAN
		do
			l_first := True
			from ports.start until ports.after loop
				if not l_first then
					a_result.append (",")
				end
				a_result.append ("{%"name%":%"" + ports.item.name + "%",")
				a_result.append ("%"containerPort%":" + ports.item.port.out + "}")
				l_first := False
				ports.forth
			end
		end

	append_env_vars (a_result: STRING)
			-- Append environment variables as JSON.
		local
			l_first: BOOLEAN
		do
			l_first := True
			from environment.start until environment.after loop
				if not l_first then
					a_result.append (",")
				end
				a_result.append ("{%"name%":%"" + environment.key_for_iteration + "%",")
				a_result.append ("%"value%":%"" + escape_json (environment.item_for_iteration) + "%"}")
				l_first := False
				environment.forth
			end
		end

	append_resources (a_result: STRING)
			-- Append resource limits as JSON.
		local
			l_need_comma: BOOLEAN
		do
			if attached cpu_request as cr or attached memory_request as mr then
				a_result.append ("%"requests%":{")
				if attached cpu_request as cr2 then
					a_result.append ("%"cpu%":%"" + cr2 + "%"")
					l_need_comma := True
				end
				if attached memory_request as mr2 then
					if l_need_comma then a_result.append (",") end
					a_result.append ("%"memory%":%"" + mr2 + "%"")
				end
				a_result.append ("}")
				l_need_comma := True
			end

			if attached cpu_limit as cl or attached memory_limit as ml then
				if l_need_comma then a_result.append (",") end
				a_result.append ("%"limits%":{")
				l_need_comma := False
				if attached cpu_limit as cl2 then
					a_result.append ("%"cpu%":%"" + cl2 + "%"")
					l_need_comma := True
				end
				if attached memory_limit as ml2 then
					if l_need_comma then a_result.append (",") end
					a_result.append ("%"memory%":%"" + ml2 + "%"")
				end
				a_result.append ("}")
			end
		end

	append_volume_mounts (a_result: STRING)
			-- Append volume mounts as JSON.
		local
			l_first: BOOLEAN
		do
			l_first := True
			from volumes.start until volumes.after loop
				if not l_first then
					a_result.append (",")
				end
				a_result.append ("{%"name%":%"" + volumes.item.name + "%",")
				a_result.append ("%"mountPath%":%"" + volumes.item.mount_path + "%"}")
				l_first := False
				volumes.forth
			end
		end

	append_volumes (a_result: STRING)
			-- Append volume definitions as JSON.
		local
			l_first: BOOLEAN
		do
			l_first := True
			from volumes.start until volumes.after loop
				if not l_first then
					a_result.append (",")
				end
				a_result.append ("{%"name%":%"" + volumes.item.name + "%",")
				-- For simplicity, treat source as emptyDir or hostPath
				if volumes.item.source.is_empty then
					a_result.append ("%"emptyDir%":{}}")
				else
					a_result.append ("%"hostPath%":{%"path%":%"" + volumes.item.source + "%"}}")
				end
				l_first := False
				volumes.forth
			end
		end

	escape_json (a_string: STRING): STRING
			-- Escape special characters for JSON.
		local
			i: INTEGER
			c: CHARACTER
		do
			create Result.make (a_string.count)
			from i := 1 until i > a_string.count loop
				c := a_string.item (i)
				inspect c
				when '"' then Result.append ("\%"")
				when '\' then Result.append ("\\")
				when '%N' then Result.append ("\n")
				when '%R' then Result.append ("\r")
				when '%T' then Result.append ("\t")
				else
					Result.append_character (c)
				end
				i := i + 1
			end
		end

invariant
	name_not_void: name /= Void
	image_not_void: image /= Void
	namespace_not_void: namespace /= Void
	restart_policy_valid: restart_policy.same_string ("Always") or
	                      restart_policy.same_string ("OnFailure") or
	                      restart_policy.same_string ("Never")
	environment_not_void: environment /= Void
	ports_not_void: ports /= Void
	volumes_not_void: volumes /= Void
	labels_not_void: labels /= Void
	annotations_not_void: annotations /= Void

end
