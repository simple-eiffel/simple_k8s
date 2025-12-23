note
	description: "Service port specification for Kubernetes services"
	author: "Larry Rix"
	DBC: "Preconditions ensure valid port configurations"

class
	SERVICE_PORT

create
	make,
	make_simple

feature {NONE} -- Initialization

	make (a_name: STRING; a_port, a_target_port: INTEGER)
			-- Create service port with explicit ports.
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
			target_valid: a_target_port > 0 and a_target_port <= 65535
		do
			name := a_name
			port := a_port
			target_port := a_target_port
			protocol := "TCP"
		ensure
			name_set: name.same_string (a_name)
			port_set: port = a_port
			target_set: target_port = a_target_port
			default_protocol: protocol.same_string ("TCP")
		end

	make_simple (a_port: INTEGER)
			-- Create service port where port = target_port.
		require
			port_valid: a_port > 0 and a_port <= 65535
		do
			name := "port-" + a_port.out
			port := a_port
			target_port := a_port
			protocol := "TCP"
		ensure
			port_set: port = a_port
			target_same: target_port = a_port
		end

feature -- Access

	name: STRING
			-- Port name (required for multi-port services).

	port: INTEGER
			-- Service port (exposed externally).

	target_port: INTEGER
			-- Container port (pod's port).

	protocol: STRING
			-- Protocol: "TCP" or "UDP" (default: "TCP").

	node_port: INTEGER
			-- NodePort (only for NodePort services, 30000-32767).

feature -- Fluent Builder

	set_name (a_name: STRING): like Current
			-- Set port name (fluent).
		require
			not_empty: not a_name.is_empty
		do
			name := a_name
			Result := Current
		ensure
			name_set: name.same_string (a_name)
		end

	set_protocol (a_protocol: STRING): like Current
			-- Set protocol: "TCP" or "UDP" (fluent).
		require
			valid: a_protocol.same_string ("TCP") or a_protocol.same_string ("UDP")
		do
			protocol := a_protocol
			Result := Current
		ensure
			protocol_set: protocol.same_string (a_protocol)
		end

	set_tcp: like Current
			-- Use TCP protocol (fluent).
		do
			protocol := "TCP"
			Result := Current
		ensure
			protocol_set: protocol.same_string ("TCP")
		end

	set_udp: like Current
			-- Use UDP protocol (fluent).
		do
			protocol := "UDP"
			Result := Current
		ensure
			protocol_set: protocol.same_string ("UDP")
		end

	set_node_port (a_node_port: INTEGER): like Current
			-- Set NodePort value (fluent).
		require
			valid_range: a_node_port >= 30000 and a_node_port <= 32767
		do
			node_port := a_node_port
			Result := Current
		ensure
			node_port_set: node_port = a_node_port
		end

feature -- Validation

	is_valid: BOOLEAN
			-- Is port specification valid?
		do
			Result := port > 0 and port <= 65535 and
			          target_port > 0 and target_port <= 65535
		end

	has_node_port: BOOLEAN
			-- Is a NodePort specified?
		do
			Result := node_port >= 30000 and node_port <= 32767
		end

feature -- Output

	to_json: STRING
			-- Generate JSON fragment for this port.
		require
			valid: is_valid
		local
			l_result: STRING
		do
			create l_result.make (128)
			l_result.append ("{")
			l_result.append ("%"name%":%"" + name + "%",")
			l_result.append ("%"port%":" + port.out + ",")
			l_result.append ("%"targetPort%":" + target_port.out + ",")
			l_result.append ("%"protocol%":%"" + protocol + "%"")
			if has_node_port then
				l_result.append (",%"nodePort%":" + node_port.out)
			end
			l_result.append ("}")
			Result := l_result
		ensure
			result_not_empty: not Result.is_empty
		end

invariant
	-- Domain invariants (void safety handles attached attributes)
	port_valid: port > 0 and port <= 65535
	target_port_valid: target_port > 0 and target_port <= 65535
	protocol_valid: protocol.same_string ("TCP") or protocol.same_string ("UDP")
	node_port_valid: node_port = 0 or (node_port >= 30000 and node_port <= 32767)

end
