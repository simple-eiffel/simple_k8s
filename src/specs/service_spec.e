note
	description: "Service specification with fluent builder pattern for Kubernetes service creation"
	author: "Larry Rix"
	DBC: "Preconditions validate all configurations before API submission"

class
	SERVICE_SPEC

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty service specification.
		do
			name := ""
			namespace := "default"
			service_type := "ClusterIP"
			create selector.make (10)
			create ports.make (5)
			create labels.make (10)
			create annotations.make (10)
		ensure
			default_namespace: namespace.same_string ("default")
			default_type: service_type.same_string ("ClusterIP")
		end

feature -- Required Configuration

	name: STRING assign set_name_direct
			-- Service name (must be valid DNS subdomain).

feature -- Optional Configuration

	namespace: STRING
			-- Target namespace (default: "default").

	service_type: STRING
			-- Service type: "ClusterIP", "NodePort", "LoadBalancer", or "ExternalName".

	selector: HASH_TABLE [STRING, STRING]
			-- Pod selector labels.

	ports: ARRAYED_LIST [SERVICE_PORT]
			-- Service ports.

	labels: HASH_TABLE [STRING, STRING]
			-- Service labels.

	annotations: HASH_TABLE [STRING, STRING]
			-- Service annotations.

	cluster_ip: detachable STRING
			-- Explicit ClusterIP ("None" for headless).

	external_name: detachable STRING
			-- External name (only for ExternalName type).

	load_balancer_ip: detachable STRING
			-- Requested load balancer IP (if supported by cloud).

	session_affinity: detachable STRING
			-- Session affinity: "None" or "ClientIP".

feature -- Fluent Builder: Required

	set_name (a_name: STRING): like Current
			-- Set service name (fluent).
		require
			valid_name: is_valid_k8s_name (a_name)
		do
			name := a_name
			-- Auto-add "app" label
			if not labels.has ("app") then
				labels.force (a_name, "app")
			end
			Result := Current
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Fluent Builder: Service Type

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

	set_cluster_ip_type: like Current
			-- Use ClusterIP service type (default, fluent).
		do
			service_type := "ClusterIP"
			Result := Current
		ensure
			type_set: service_type.same_string ("ClusterIP")
		end

	set_node_port_type: like Current
			-- Use NodePort service type (fluent).
		do
			service_type := "NodePort"
			Result := Current
		ensure
			type_set: service_type.same_string ("NodePort")
		end

	set_load_balancer_type: like Current
			-- Use LoadBalancer service type (fluent).
		do
			service_type := "LoadBalancer"
			Result := Current
		ensure
			type_set: service_type.same_string ("LoadBalancer")
		end

	set_external_name_type (a_external_name: STRING): like Current
			-- Use ExternalName service type (fluent).
		require
			name_not_empty: not a_external_name.is_empty
		do
			service_type := "ExternalName"
			external_name := a_external_name
			Result := Current
		ensure
			type_set: service_type.same_string ("ExternalName")
			external_name_set: attached external_name as en and then en.same_string (a_external_name)
		end

	set_headless: like Current
			-- Create headless service (ClusterIP: None, fluent).
		do
			service_type := "ClusterIP"
			cluster_ip := "None"
			Result := Current
		ensure
			type_set: service_type.same_string ("ClusterIP")
			headless: attached cluster_ip as cip and then cip.same_string ("None")
		end

feature -- Fluent Builder: Configuration

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

	select_app (a_app_name: STRING): like Current
			-- Convenience: select pods with "app" label (fluent).
		require
			not_empty: not a_app_name.is_empty
		do
			selector.force (a_app_name, "app")
			Result := Current
		ensure
			selector_set: selector.has ("app")
		end

	add_port (a_port: SERVICE_PORT): like Current
			-- Add service port (fluent).
		require
			port_valid: a_port.is_valid
		do
			ports.extend (a_port)
			Result := Current
		ensure
			port_added: ports.count = old ports.count + 1
		end

	add_simple_port (a_port: INTEGER): like Current
			-- Add simple port where service port = target port (fluent).
		require
			valid_port: a_port > 0 and a_port <= 65535
		do
			ports.extend (create {SERVICE_PORT}.make_simple (a_port))
			Result := Current
		ensure
			port_added: ports.count = old ports.count + 1
		end

	add_port_mapping (a_name: STRING; a_port, a_target_port: INTEGER): like Current
			-- Add port with explicit mapping (fluent).
		require
			name_not_empty: not a_name.is_empty
			ports_valid: a_port > 0 and a_port <= 65535 and a_target_port > 0 and a_target_port <= 65535
		do
			ports.extend (create {SERVICE_PORT}.make (a_name, a_port, a_target_port))
			Result := Current
		ensure
			port_added: ports.count = old ports.count + 1
		end

	add_label (a_key, a_value: STRING): like Current
			-- Add service label (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			labels.force (a_value, a_key)
			Result := Current
		ensure
			label_added: labels.has (a_key)
		end

	add_annotation (a_key, a_value: STRING): like Current
			-- Add service annotation (fluent).
		require
			key_not_empty: not a_key.is_empty
		do
			annotations.force (a_value, a_key)
			Result := Current
		ensure
			annotation_added: annotations.has (a_key)
		end

	set_load_balancer_ip (a_ip: STRING): like Current
			-- Request specific load balancer IP (fluent).
		require
			not_empty: not a_ip.is_empty
		do
			load_balancer_ip := a_ip
			Result := Current
		ensure
			ip_set: attached load_balancer_ip as lbip and then lbip.same_string (a_ip)
		end

	set_session_affinity_none: like Current
			-- No session affinity (fluent).
		do
			session_affinity := "None"
			Result := Current
		ensure
			affinity_set: attached session_affinity as sa and then sa.same_string ("None")
		end

	set_session_affinity_client_ip: like Current
			-- Use ClientIP session affinity (fluent).
		do
			session_affinity := "ClientIP"
			Result := Current
		ensure
			affinity_set: attached session_affinity as sa and then sa.same_string ("ClientIP")
		end

feature -- Direct Setters (non-fluent, for assign)

	set_name_direct (a_name: STRING)
			-- Set service name directly.
		require
			valid_name: is_valid_k8s_name (a_name)
		do
			name := a_name
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Validation

	is_valid: BOOLEAN
			-- Is specification valid for submission to K8s API?
		do
			Result := not name.is_empty and
			          (service_type.same_string ("ExternalName") or not selector.is_empty) and
			          (service_type.same_string ("ExternalName") or not ports.is_empty)
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
			create l_result.make (1024)
			l_result.append ("{")

			-- API Version and Kind
			l_result.append ("%"apiVersion%":%"v1%",")
			l_result.append ("%"kind%":%"Service%",")

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
			l_result.append ("%"type%":%"" + service_type + "%"")

			-- ClusterIP
			if attached cluster_ip as cip then
				l_result.append (",%"clusterIP%":%"" + cip + "%"")
			end

			-- ExternalName
			if service_type.same_string ("ExternalName") and attached external_name as en then
				l_result.append (",%"externalName%":%"" + en + "%"")
			end

			-- LoadBalancer IP
			if attached load_balancer_ip as lbip then
				l_result.append (",%"loadBalancerIP%":%"" + lbip + "%"")
			end

			-- Session Affinity
			if attached session_affinity as sa then
				l_result.append (",%"sessionAffinity%":%"" + sa + "%"")
			end

			-- Selector (not for ExternalName)
			if not service_type.same_string ("ExternalName") and not selector.is_empty then
				l_result.append (",%"selector%":{")
				append_string_map (l_result, selector)
				l_result.append ("}")
			end

			-- Ports (not for ExternalName)
			if not service_type.same_string ("ExternalName") and not ports.is_empty then
				l_result.append (",%"ports%":[")
				append_ports (l_result)
				l_result.append ("]")
			end

			l_result.append ("}")  -- Close spec
			l_result.append ("}")  -- Close root

			Result := l_result
		ensure
			result_not_empty: not Result.is_empty
		end

feature {NONE} -- JSON Helpers

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

	append_ports (a_result: STRING)
			-- Append service ports as JSON.
		local
			l_first: BOOLEAN
		do
			l_first := True
			from ports.start until ports.after loop
				if not l_first then
					a_result.append (",")
				end
				a_result.append (ports.item.to_json)
				l_first := False
				ports.forth
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
	service_type_valid: service_type.same_string ("ClusterIP") or
	                    service_type.same_string ("NodePort") or
	                    service_type.same_string ("LoadBalancer") or
	                    service_type.same_string ("ExternalName")

end
