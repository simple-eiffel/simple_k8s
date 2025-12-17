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
			create api
			api_server := ""
			current_namespace := "default"
		end

	make_from_file (a_path: STRING)
			-- Load config from kubeconfig file.
		require
			path_not_empty: not a_path.is_empty
		local
			l_content: detachable STRING
		do
			make
			l_content := api.read_file (a_path)
			if l_content = Void or else l_content.is_empty then
				last_error := "Cannot read file: " + a_path
			else
				if attached api.parse_yaml (l_content.to_string_32) as l_root then
					parse_kubeconfig (l_root)
				else
					last_error := "Failed to parse YAML"
				end
			end
		end

	make_in_cluster
			-- Load in-cluster config from service account.
		do
			make
			is_in_cluster := True

			-- In-cluster config uses environment and mounted files
			api_server := "https://kubernetes.default.svc"

			-- Read service account token
			if attached api.read_file ("/var/run/secrets/kubernetes.io/serviceaccount/token") as l_token then
				bearer_token := l_token
			else
				last_error := "Cannot read service account token"
			end

			-- Read namespace
			if attached api.read_file ("/var/run/secrets/kubernetes.io/serviceaccount/namespace") as l_ns then
				current_namespace := l_ns
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
			if attached api.env_get ("KUBECONFIG") as l_path and then not l_path.is_empty then
				Result := l_path.to_string_8
			elseif attached api.env_get ("HOME") as l_home then
				Result := l_home.to_string_8 + "/.kube/config"
			elseif attached api.env_get ("USERPROFILE") as l_profile then
				Result := l_profile.to_string_8 + "/.kube/config"
			end
		end

	is_in_cluster_environment: BOOLEAN
			-- Are we running inside a Kubernetes pod?
		do
			Result := api.file_exists ("/var/run/secrets/kubernetes.io/serviceaccount/token")
		end

feature {NONE} -- Implementation

	api: FOUNDATION_API
			-- Foundation API for all operations.

	parse_kubeconfig (a_root: attached like api.yaml.value_at)
			-- Parse kubeconfig YAML.
		local
			l_ctx_name: detachable STRING
		do
			if attached {like api.yaml.new_mapping} a_root as l_map then
				-- Get current-context
				if attached l_map.string_item ("current-context") as l_ctx then
					l_ctx_name := l_ctx
				end

				-- Find cluster and user from context
				if l_ctx_name /= Void then
					parse_context (l_map, l_ctx_name)
				end
			end
		end

	parse_context (a_map: attached like api.yaml.new_mapping; a_ctx_name: STRING)
			-- Parse context by name.
		do
			if attached a_map.sequence_item ("contexts") as l_contexts then
				across 1 |..| l_contexts.count as i loop
					if attached l_contexts.mapping_item (i) as l_ctx then
						if attached l_ctx.string_item ("name") as l_name and then l_name.same_string (a_ctx_name) then
							if attached l_ctx.mapping_item ("context") as l_ctx_data then
								if attached l_ctx_data.string_item ("cluster") as l_cluster_name then
									parse_cluster (a_map, l_cluster_name)
								end
								if attached l_ctx_data.string_item ("user") as l_user_name then
									parse_user (a_map, l_user_name)
								end
								if attached l_ctx_data.string_item ("namespace") as l_ns then
									current_namespace := l_ns
								end
							end
						end
					end
				end
			end
		end

	parse_cluster (a_map: attached like api.yaml.new_mapping; a_cluster_name: STRING)
			-- Parse cluster by name.
		do
			if attached a_map.sequence_item ("clusters") as l_clusters then
				across 1 |..| l_clusters.count as i loop
					if attached l_clusters.mapping_item (i) as l_cluster then
						if attached l_cluster.string_item ("name") as l_name and then l_name.same_string (a_cluster_name) then
							if attached l_cluster.mapping_item ("cluster") as l_data then
								if attached l_data.string_item ("server") as l_server then
									api_server := l_server
								end
								if attached l_data.string_item ("certificate-authority-data") as l_ca then
									certificate_authority := l_ca
								end
							end
						end
					end
				end
			end
		end

	parse_user (a_map: attached like api.yaml.new_mapping; a_user_name: STRING)
			-- Parse user by name.
		do
			if attached a_map.sequence_item ("users") as l_users then
				across 1 |..| l_users.count as i loop
					if attached l_users.mapping_item (i) as l_user then
						if attached l_user.string_item ("name") as l_name and then l_name.same_string (a_user_name) then
							if attached l_user.mapping_item ("user") as l_data then
								if attached l_data.string_item ("token") as l_token then
									bearer_token := l_token
								end
								if attached l_data.string_item ("client-certificate-data") as l_cert then
									client_certificate := l_cert
								end
								if attached l_data.string_item ("client-key-data") as l_key then
									client_key := l_key
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
	api_not_void: api /= Void

end
