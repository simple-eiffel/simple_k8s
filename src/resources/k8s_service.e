note
	description: "Kubernetes Service resource representation"
	author: "Larry Rix"

class
	K8S_SERVICE

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
			service_type := "ClusterIP"
			create labels.make (10)
			create annotations.make (10)
			create selector.make (10)
			create ports.make (5)
			create external_ips.make (3)
		ensure
			name_set: name.same_string (a_name)
			namespace_set: namespace.same_string (a_namespace)
		end

	make_from_json (a_json: STRING)
			-- Parse service from JSON response.
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

	service_type: STRING

	cluster_ip: detachable STRING

	external_ip: detachable STRING

	load_balancer_ip: detachable STRING

	external_name: detachable STRING

	labels: HASH_TABLE [STRING, STRING]

	annotations: HASH_TABLE [STRING, STRING]

	selector: HASH_TABLE [STRING, STRING]

	ports: ARRAYED_LIST [TUPLE [name: STRING; port: INTEGER; target_port: INTEGER; node_port: INTEGER; protocol: STRING]]

	external_ips: ARRAYED_LIST [STRING]

feature -- Status

	is_cluster_ip: BOOLEAN
		do
			Result := service_type.same_string ("ClusterIP")
		end

	is_node_port: BOOLEAN
		do
			Result := service_type.same_string ("NodePort")
		end

	is_load_balancer: BOOLEAN
		do
			Result := service_type.same_string ("LoadBalancer")
		end

	is_external_name: BOOLEAN
		do
			Result := service_type.same_string ("ExternalName")
		end

	has_external_ip: BOOLEAN
		do
			Result := external_ip /= Void or load_balancer_ip /= Void
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
			Result.append ("Type: " + service_type + "%N")
			if attached cluster_ip as cip then
				Result.append ("ClusterIP: " + cip + "%N")
			end
			if attached external_ip as eip then
				Result.append ("ExternalIP: " + eip + "%N")
			end
			if attached load_balancer_ip as lbip then
				Result.append ("LoadBalancer IP: " + lbip + "%N")
			end
			if attached external_name as en then
				Result.append ("ExternalName: " + en + "%N")
			end
			if not ports.is_empty then
				Result.append ("Ports:%N")
				from ports.start until ports.after loop
					Result.append ("  " + ports.item.port.out + "/" + ports.item.protocol)
					if ports.item.target_port > 0 then
						Result.append (" -> " + ports.item.target_port.out)
					end
					if ports.item.node_port > 0 then
						Result.append (" (NodePort: " + ports.item.node_port.out + ")")
					end
					if not ports.item.name.is_empty then
						Result.append (" [" + ports.item.name + "]")
					end
					Result.append ("%N")
					ports.forth
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
		do
			name := "unknown"
			namespace := "default"
			service_type := "ClusterIP"
			create labels.make (10)
			create annotations.make (10)
			create selector.make (10)
			create ports.make (5)
			create external_ips.make (3)

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
				if attached l_spec.string_item ("type") as t then
					service_type := t.to_string_8
				end
				if attached l_spec.string_item ("clusterIP") as cip then
					cluster_ip := cip.to_string_8
				end
				if attached l_spec.string_item ("externalName") as en then
					external_name := en.to_string_8
				end
				parse_string_map (l_spec.object_item ("selector"), selector)
				parse_ports (l_spec.array_item ("ports"))
				parse_external_ips (l_spec.array_item ("externalIPs"))
			end

			l_status := a_root.object_item ("status")
			if attached l_status then
				if attached l_status.object_item ("loadBalancer") as lb then
					if attached lb.array_item ("ingress") as ingress then
						if ingress.count > 0 then
							if attached ingress.object_at (1) as first_ingress then
								if attached first_ingress.string_item ("ip") as ip then
									load_balancer_ip := ip.to_string_8
									external_ip := ip.to_string_8
								elseif attached first_ingress.string_item ("hostname") as hostname then
									load_balancer_ip := hostname.to_string_8
								end
							end
						end
					end
				end
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

	parse_ports (a_arr: detachable like api.new_json_array)
		local
			i: INTEGER
			l_name, l_protocol: STRING
			l_port, l_target_port, l_node_port: INTEGER
		do
			if attached a_arr then
				from i := 1 until i > a_arr.count loop
					if attached a_arr.object_at (i) as p then
						l_name := ""
						l_protocol := "TCP"
						l_port := 0
						l_target_port := 0
						l_node_port := 0
						if attached p.string_item ("name") as n then
							l_name := n.to_string_8
						end
						if attached p.string_item ("protocol") as proto then
							l_protocol := proto.to_string_8
						end
						l_port := p.integer_item ("port").to_integer_32
						l_target_port := p.integer_item ("targetPort").to_integer_32
						l_node_port := p.integer_item ("nodePort").to_integer_32
						ports.extend ([l_name, l_port, l_target_port, l_node_port, l_protocol])
					end
					i := i + 1
				end
			end
		end

	parse_external_ips (a_arr: detachable like api.new_json_array)
		local
			i: INTEGER
		do
			if attached a_arr then
				from i := 1 until i > a_arr.count loop
					if attached a_arr.string_at (i) as ip then
						external_ips.extend (ip.to_string_8)
						if i = 1 then
							external_ip := ip.to_string_8
						end
					end
					i := i + 1
				end
			end
		end

invariant
	api_not_void: api /= Void
	name_not_void: name /= Void
	namespace_not_void: namespace /= Void
	service_type_not_void: service_type /= Void

end
