note
	description: "Deployment specification with fluent builder pattern for Kubernetes deployment creation"
	author: "Larry Rix"
	DBC: "Preconditions validate all configurations before API submission"

class
	DEPLOYMENT_SPEC

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty deployment specification.
		do
			name := ""
			image := ""
			namespace := "default"
			replicas := 1
			strategy := "RollingUpdate"
			max_unavailable := "25%%"
			max_surge := "25%%"
			create environment.make (10)
			create ports.make (5)
			create labels.make (10)
			create selector.make (10)
			create annotations.make (10)
		ensure
			default_namespace: namespace.same_string ("default")
			default_replicas: replicas = 1
			default_strategy: strategy.same_string ("RollingUpdate")
		end

feature -- Required Configuration

	name: STRING assign set_name_direct
			-- Deployment name (must be valid DNS subdomain).

	image: STRING assign set_image_direct
			-- Container image (e.g., "nginx:alpine").

feature -- Optional Configuration

	namespace: STRING
			-- Target namespace (default: "default").

	replicas: INTEGER
			-- Number of pod replicas (default: 1).

	strategy: STRING
			-- Deployment strategy: "RollingUpdate" or "Recreate".

	max_unavailable: STRING
			-- Max unavailable during rolling update (e.g., "25%%" or "1").

	max_surge: STRING
			-- Max surge during rolling update (e.g., "25%%" or "1").

	command: detachable ARRAY [STRING]
			-- Override container entrypoint.

	args: detachable ARRAY [STRING]
			-- Arguments to the entrypoint.

	environment: HASH_TABLE [STRING, STRING]
			-- Environment variables (key -> value).

	ports: ARRAYED_LIST [TUPLE [name: STRING; port: INTEGER]]
			-- Container ports to expose.

	labels: HASH_TABLE [STRING, STRING]
			-- Deployment and pod labels.

	selector: HASH_TABLE [STRING, STRING]
			-- Pod selector labels.

	annotations: HASH_TABLE [STRING, STRING]
			-- Deployment annotations.

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
			-- Set deployment name (fluent).
		require
			valid_name: is_valid_k8s_name (a_name)
		do
			name := a_name
			-- Auto-set "app" label and selector if not already set
			if not labels.has ("app") then
				labels.force (a_name, "app")
			end
			if not selector.has ("app") then
				selector.force (a_name, "app")
			end
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

feature -- Fluent Builder: Deployment Config

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

	set_replicas (a_count: INTEGER): like Current
			-- Set number of replicas (fluent).
		require
			non_negative: a_count >= 0
		do
			replicas := a_count
			Result := Current
		ensure
			replicas_set: replicas = a_count
		end

	set_rolling_update: like Current
			-- Use RollingUpdate strategy (fluent).
		do
			strategy := "RollingUpdate"
			Result := Current
		ensure
			strategy_set: strategy.same_string ("RollingUpdate")
		end

	set_recreate: like Current
			-- Use Recreate strategy (fluent).
		do
			strategy := "Recreate"
			Result := Current
		ensure
			strategy_set: strategy.same_string ("Recreate")
		end

	set_rolling_update_params (a_max_unavailable, a_max_surge: STRING): like Current
			-- Set rolling update parameters (fluent).
		require
			not_empty: not a_max_unavailable.is_empty and not a_max_surge.is_empty
		do
			strategy := "RollingUpdate"
			max_unavailable := a_max_unavailable
			max_surge := a_max_surge
			Result := Current
		ensure
			strategy_set: strategy.same_string ("RollingUpdate")
			max_unavailable_set: max_unavailable.same_string (a_max_unavailable)
			max_surge_set: max_surge.same_string (a_max_surge)
		end

feature -- Fluent Builder: Container Config

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

	add_label (a_key, a_value: STRING): like Current
			-- Add deployment label (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			labels.force (a_value, a_key)
			Result := Current
		ensure
			label_added: labels.has (a_key)
		end

	add_selector (a_key, a_value: STRING): like Current
			-- Add pod selector (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			selector.force (a_value, a_key)
			Result := Current
		ensure
			selector_added: selector.has (a_key)
		end

	add_annotation (a_key, a_value: STRING): like Current
			-- Add deployment annotation (fluent).
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
		ensure
			cpu_request_set: attached cpu_request as cr implies cr.same_string (a_cpu_req)
			cpu_limit_set: attached cpu_limit as cl implies cl.same_string (a_cpu_lim)
			memory_request_set: attached memory_request as mr implies mr.same_string (a_mem_req)
			memory_limit_set: attached memory_limit as ml implies ml.same_string (a_mem_lim)
		end

	set_cpu (a_request, a_limit: STRING): like Current
			-- Set CPU resources (fluent).
		do
			cpu_request := a_request
			cpu_limit := a_limit
			Result := Current
		ensure
			request_set: attached cpu_request as cr implies cr.same_string (a_request)
			limit_set: attached cpu_limit as cl implies cl.same_string (a_limit)
		end

	set_memory (a_request, a_limit: STRING): like Current
			-- Set memory resources (fluent).
		do
			memory_request := a_request
			memory_limit := a_limit
			Result := Current
		ensure
			request_set: attached memory_request as mr implies mr.same_string (a_request)
			limit_set: attached memory_limit as ml implies ml.same_string (a_limit)
		end

feature -- Direct Setters (non-fluent, for assign)

	set_name_direct (a_name: STRING)
			-- Set deployment name directly.
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
			Result := not name.is_empty and
			          not image.is_empty and
			          replicas >= 0 and
			          not selector.is_empty
		ensure
			definition: Result = (not name.is_empty and not image.is_empty and
			                      replicas >= 0 and not selector.is_empty)
		end

	is_valid_k8s_name (a_name: STRING): BOOLEAN
			-- Is `a_name' a valid Kubernetes resource name?
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
			create l_result.make (2048)
			l_result.append ("{")

			-- API Version and Kind
			l_result.append ("%"apiVersion%":%"apps/v1%",")
			l_result.append ("%"kind%":%"Deployment%",")

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
			l_result.append ("%"replicas%":" + replicas.out + ",")

			-- Selector
			l_result.append ("%"selector%":{%"matchLabels%":{")
			append_string_map (l_result, selector)
			l_result.append ("}},")

			-- Strategy
			l_result.append ("%"strategy%":{%"type%":%"" + strategy + "%"")
			if strategy.same_string ("RollingUpdate") then
				l_result.append (",%"rollingUpdate%":{")
				l_result.append ("%"maxUnavailable%":%"" + max_unavailable + "%",")
				l_result.append ("%"maxSurge%":%"" + max_surge + "%"}")
			end
			l_result.append ("},")

			-- Template
			l_result.append ("%"template%":{")

			-- Template Metadata
			l_result.append ("%"metadata%":{%"labels%":{")
			append_string_map (l_result, selector)
			l_result.append ("}},")

			-- Template Spec (pod spec)
			l_result.append ("%"spec%":{")
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

			l_result.append ("}]")  -- Close containers array
			l_result.append ("}")   -- Close pod spec
			l_result.append ("}")   -- Close template
			l_result.append ("}")   -- Close deployment spec
			l_result.append ("}")   -- Close root

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
	-- Domain invariants (void safety handles attached attributes)
	replicas_non_negative: replicas >= 0
	strategy_valid: strategy.same_string ("RollingUpdate") or strategy.same_string ("Recreate")

end
