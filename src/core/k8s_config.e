note
	description: "Kubernetes configuration (kubeconfig parser)"
	author: "Larry Rix"

class
	K8S_CONFIG

create
	make,
	make_from_file,
	make_in_cluster

feature {NONE} -- Initialization

	make
			-- Create empty config.
		do
			create env
			create yaml.make
			api_server := ""
			current_namespace := "default"
		end

	make_from_file (a_path: STRING)
			-- Load config from kubeconfig file.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: SIMPLE_FILE
			l_content: STRING_32
		do
			make
			create l_file.make (a_path)
			if l_file.exists then
				l_content := l_file.content
				if l_content.is_empty then
					last_error := "Cannot read file: " + a_path
				else
					if attached yaml.parse (l_content.to_string_8) as l_root then
						parse_kubeconfig (l_root)
					else
						last_error := "Failed to parse YAML"
					end
				end
			else
				last_error := "Cannot read file: " + a_path
			end
		end

	make_in_cluster
			-- Load in-cluster config from service account.
		local
			l_token_file, l_ns_file: SIMPLE_FILE
		do
			make
			is_in_cluster := True

			-- In-cluster config uses environment and mounted files
			api_server := "https://kubernetes.default.svc"

			-- Read service account token
			create l_token_file.make ("/var/run/secrets/kubernetes.io/serviceaccount/token")
			if l_token_file.exists then
				bearer_token := l_token_file.content.to_string_8
			else
				last_error := "Cannot read service account token"
			end

			-- Read namespace
			create l_ns_file.make ("/var/run/secrets/kubernetes.io/serviceaccount/namespace")
			if l_ns_file.exists then
				current_namespace := l_ns_file.content.to_string_8
			end
		end

feature -- Access

	api_server: STRING
			-- Kubernetes API server URL.

	current_namespace: STRING
			-- Current namespace.

	bearer_token: detachable STRING
			-- Bearer token for authentication.

	client_certificate: detachable STRING
			-- Client certificate data (base64).

	client_key: detachable STRING
			-- Client key data (base64).

	certificate_authority: detachable STRING
			-- CA certificate data (base64).

	is_in_cluster: BOOLEAN
			-- Running inside a Kubernetes pod?

	last_error: detachable STRING
			-- Last error message.

feature -- Status

	is_valid: BOOLEAN
			-- Is config valid for use?
		do
			Result := not api_server.is_empty and then last_error = Void
		end

	has_error: BOOLEAN
			-- Was there an error loading config?
		do
			Result := last_error /= Void
		end

	default_config_path: detachable STRING
			-- Default kubeconfig path.
		do
			if attached env.get ("KUBECONFIG") as l_path and then not l_path.is_empty then
				Result := l_path.to_string_8
			elseif attached env.get ("HOME") as l_home then
				Result := l_home.to_string_8 + "/.kube/config"
			elseif attached env.get ("USERPROFILE") as l_profile then
				Result := l_profile.to_string_8 + "/.kube/config"
			end
		end

	is_in_cluster_environment: BOOLEAN
			-- Are we running inside a Kubernetes pod?
		local
			l_file: SIMPLE_FILE
		do
			create l_file.make ("/var/run/secrets/kubernetes.io/serviceaccount/token")
			Result := l_file.exists
		end

feature {NONE} -- Implementation

	env: SIMPLE_ENV
			-- Environment variable access.

	yaml: SIMPLE_YAML_QUICK
			-- YAML parser.

	parse_kubeconfig (a_root: YAML_VALUE)
			-- Parse kubeconfig YAML.
		local
			l_ctx_name: detachable STRING_32
		do
			if attached {YAML_MAPPING} a_root as l_map then
				-- Get current-context
				if attached l_map.string_item ("current-context") as l_ctx then
					l_ctx_name := l_ctx
				end

				-- Find cluster and user from context
				if l_ctx_name /= Void then
					parse_context (l_map, l_ctx_name.to_string_8)
				end
			end
		end

	parse_context (a_map: YAML_MAPPING; a_ctx_name: STRING)
			-- Parse context by name.
		do
			if attached a_map.sequence_item ("contexts") as l_contexts then
				across 1 |..| l_contexts.count as i loop
					if attached l_contexts.mapping_item (i) as l_ctx then
						if attached l_ctx.string_item ("name") as l_name and then l_name.same_string_general (a_ctx_name) then
							if attached l_ctx.mapping_item ("context") as l_ctx_data then
								if attached l_ctx_data.string_item ("cluster") as l_cluster_name then
									parse_cluster (a_map, l_cluster_name.to_string_8)
								end
								if attached l_ctx_data.string_item ("user") as l_user_name then
									parse_user (a_map, l_user_name.to_string_8)
								end
								if attached l_ctx_data.string_item ("namespace") as l_ns then
									current_namespace := l_ns.to_string_8
								end
							end
						end
					end
				end
			end
		end

	parse_cluster (a_map: YAML_MAPPING; a_cluster_name: STRING)
			-- Parse cluster by name.
		do
			if attached a_map.sequence_item ("clusters") as l_clusters then
				across 1 |..| l_clusters.count as i loop
					if attached l_clusters.mapping_item (i) as l_cluster then
						if attached l_cluster.string_item ("name") as l_name and then l_name.same_string_general (a_cluster_name) then
							if attached l_cluster.mapping_item ("cluster") as l_data then
								if attached l_data.string_item ("server") as l_server then
									api_server := l_server.to_string_8
								end
								if attached l_data.string_item ("certificate-authority-data") as l_ca then
									certificate_authority := l_ca.to_string_8
								end
							end
						end
					end
				end
			end
		end

	parse_user (a_map: YAML_MAPPING; a_user_name: STRING)
			-- Parse user by name.
		do
			if attached a_map.sequence_item ("users") as l_users then
				across 1 |..| l_users.count as i loop
					if attached l_users.mapping_item (i) as l_user then
						if attached l_user.string_item ("name") as l_name and then l_name.same_string_general (a_user_name) then
							if attached l_user.mapping_item ("user") as l_data then
								if attached l_data.string_item ("token") as l_token then
									bearer_token := l_token.to_string_8
								end
								if attached l_data.string_item ("client-certificate-data") as l_cert then
									client_certificate := l_cert.to_string_8
								end
								if attached l_data.string_item ("client-key-data") as l_key then
									client_key := l_key.to_string_8
								end
							end
						end
					end
				end
			end
		end

invariant
	namespace_not_void: current_namespace /= Void
	api_server_not_void: api_server /= Void
	env_not_void: env /= Void
	yaml_not_void: yaml /= Void

end
