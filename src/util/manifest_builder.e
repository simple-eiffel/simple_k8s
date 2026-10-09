note
	description: "[
		YAML manifest builder for Kubernetes resources.

		Generates valid YAML manifests that can be applied with kubectl apply -f.
		Supports multi-document manifests (separated by ---).

		Example:
			create builder.make
			builder.add_namespace ("production")
			builder.add_deployment ("web-app", "nginx:alpine", 3)
			builder.add_service_lb ("web-app", 80)

			-- Output to file for kubectl apply
			builder.save_to_file ("manifest.yaml")

			-- Or get as string
			print (builder.to_yaml)
	]"
	author: "Larry Rix"

class
	MANIFEST_BUILDER

inherit
	ANY
		redefine
			default_create
		end

create
	make, default_create

feature {NONE} -- Initialization

	default_create
			-- Create empty manifest builder.
		do
			make
		end

	make
			-- Create empty manifest builder.
		do
			create documents.make (10)
			default_namespace := "default"
		ensure
			empty: documents.is_empty
			default_ns: default_namespace.same_string ("default")
		end

feature -- Access

	default_namespace: STRING
			-- Default namespace for resources.

	document_count: INTEGER
			-- Number of resources in manifest.
		do
			Result := documents.count
		end

	is_empty: BOOLEAN
			-- Is manifest empty?
		do
			Result := documents.is_empty
		end

feature -- Configuration

	set_default_namespace (a_namespace: STRING)
			-- Set default namespace for subsequent resources.
		require
			not_empty: not a_namespace.is_empty
		do
			default_namespace := a_namespace
		ensure
			namespace_set: default_namespace.same_string (a_namespace)
		end

feature -- Namespace

	add_namespace (a_name: STRING)
			-- Add namespace resource.
		require
			name_not_empty: not a_name.is_empty
		local
			l_yaml: STRING
		do
			create l_yaml.make (200)
			l_yaml.append ("apiVersion: v1%N")
			l_yaml.append ("kind: Namespace%N")
			l_yaml.append ("metadata:%N")
			l_yaml.append ("  name: " + a_name + "%N")
			documents.extend (l_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- Pod

	add_pod (a_name, a_image: STRING)
			-- Add simple pod.
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
		do
			add_pod_full (a_name, default_namespace, a_image, Void)
		ensure
			added: document_count = old document_count + 1
		end

	add_pod_full (a_name, a_namespace, a_image: STRING; a_command: detachable ARRAY [STRING])
			-- Add pod with full options.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			image_not_empty: not a_image.is_empty
		local
			l_yaml: STRING
		do
			create l_yaml.make (500)
			l_yaml.append ("apiVersion: v1%N")
			l_yaml.append ("kind: Pod%N")
			l_yaml.append ("metadata:%N")
			l_yaml.append ("  name: " + a_name + "%N")
			l_yaml.append ("  namespace: " + a_namespace + "%N")
			l_yaml.append ("spec:%N")
			l_yaml.append ("  containers:%N")
			l_yaml.append ("  - name: " + a_name + "%N")
			l_yaml.append ("    image: " + a_image + "%N")
			if attached a_command as cmd and then cmd.count > 0 then
				l_yaml.append ("    command:%N")
				across cmd.lower |..| cmd.upper as i loop
					l_yaml.append ("    - %"" + cmd [i.item] + "%"%N")
				end
			end
			documents.extend (l_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- Deployment

	add_deployment (a_name, a_image: STRING; a_replicas: INTEGER)
			-- Add deployment.
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
			replicas_valid: a_replicas >= 0
		do
			add_deployment_full (a_name, default_namespace, a_image, a_replicas, 80)
		ensure
			added: document_count = old document_count + 1
		end

	add_deployment_full (a_name, a_namespace, a_image: STRING; a_replicas, a_port: INTEGER)
			-- Add deployment with full options.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			image_not_empty: not a_image.is_empty
			replicas_valid: a_replicas >= 0
			port_valid: a_port > 0 and a_port <= 65535
		local
			l_yaml: STRING
		do
			create l_yaml.make (800)
			l_yaml.append ("apiVersion: apps/v1%N")
			l_yaml.append ("kind: Deployment%N")
			l_yaml.append ("metadata:%N")
			l_yaml.append ("  name: " + a_name + "%N")
			l_yaml.append ("  namespace: " + a_namespace + "%N")
			l_yaml.append ("spec:%N")
			l_yaml.append ("  replicas: " + a_replicas.out + "%N")
			l_yaml.append ("  selector:%N")
			l_yaml.append ("    matchLabels:%N")
			l_yaml.append ("      app: " + a_name + "%N")
			l_yaml.append ("  template:%N")
			l_yaml.append ("    metadata:%N")
			l_yaml.append ("      labels:%N")
			l_yaml.append ("        app: " + a_name + "%N")
			l_yaml.append ("    spec:%N")
			l_yaml.append ("      containers:%N")
			l_yaml.append ("      - name: " + a_name + "%N")
			l_yaml.append ("        image: " + a_image + "%N")
			l_yaml.append ("        ports:%N")
			l_yaml.append ("        - containerPort: " + a_port.out + "%N")
			documents.extend (l_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- Service

	add_service (a_name: STRING; a_port: INTEGER)
			-- Add ClusterIP service.
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
		do
			add_service_full (a_name, default_namespace, "ClusterIP", a_port, a_port, 0)
		ensure
			added: document_count = old document_count + 1
		end

	add_service_lb (a_name: STRING; a_port: INTEGER)
			-- Add LoadBalancer service.
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
		do
			add_service_full (a_name, default_namespace, "LoadBalancer", a_port, a_port, 0)
		ensure
			added: document_count = old document_count + 1
		end

	add_service_nodeport (a_name: STRING; a_port, a_nodeport: INTEGER)
			-- Add NodePort service.
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
			nodeport_valid: a_nodeport >= 30000 and a_nodeport <= 32767
		do
			add_service_full (a_name, default_namespace, "NodePort", a_port, a_port, a_nodeport)
		ensure
			added: document_count = old document_count + 1
		end

	add_service_full (a_name, a_namespace, a_type: STRING; a_port, a_target_port, a_nodeport: INTEGER)
			-- Add service with full options.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			type_valid: a_type.same_string ("ClusterIP") or a_type.same_string ("NodePort") or a_type.same_string ("LoadBalancer")
			port_valid: a_port > 0 and a_port <= 65535
			target_valid: a_target_port > 0 and a_target_port <= 65535
		local
			l_yaml: STRING
		do
			create l_yaml.make (500)
			l_yaml.append ("apiVersion: v1%N")
			l_yaml.append ("kind: Service%N")
			l_yaml.append ("metadata:%N")
			l_yaml.append ("  name: " + a_name + "%N")
			l_yaml.append ("  namespace: " + a_namespace + "%N")
			l_yaml.append ("spec:%N")
			l_yaml.append ("  type: " + a_type + "%N")
			l_yaml.append ("  selector:%N")
			l_yaml.append ("    app: " + a_name + "%N")
			l_yaml.append ("  ports:%N")
			l_yaml.append ("  - port: " + a_port.out + "%N")
			l_yaml.append ("    targetPort: " + a_target_port.out + "%N")
			if a_nodeport > 0 then
				l_yaml.append ("    nodePort: " + a_nodeport.out + "%N")
			end
			documents.extend (l_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- ConfigMap

	add_configmap (a_name: STRING; a_data: HASH_TABLE [STRING, STRING])
			-- Add configmap with data.
		require
			name_not_empty: not a_name.is_empty
			data_not_void: a_data /= Void
		local
			l_yaml: STRING
		do
			create l_yaml.make (500)
			l_yaml.append ("apiVersion: v1%N")
			l_yaml.append ("kind: ConfigMap%N")
			l_yaml.append ("metadata:%N")
			l_yaml.append ("  name: " + a_name + "%N")
			l_yaml.append ("  namespace: " + default_namespace + "%N")
			if not a_data.is_empty then
				l_yaml.append ("data:%N")
				from a_data.start until a_data.after loop
					l_yaml.append ("  " + a_data.key_for_iteration + ": %"" + a_data.item_for_iteration + "%"%N")
					a_data.forth
				end
			end
			documents.extend (l_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- Secret

	add_secret_opaque (a_name: STRING; a_data: HASH_TABLE [STRING, STRING])
			-- Add opaque secret (values will be base64 encoded).
		require
			name_not_empty: not a_name.is_empty
			data_not_void: a_data /= Void
		local
			l_yaml: STRING
		do
			create l_yaml.make (500)
			l_yaml.append ("apiVersion: v1%N")
			l_yaml.append ("kind: Secret%N")
			l_yaml.append ("metadata:%N")
			l_yaml.append ("  name: " + a_name + "%N")
			l_yaml.append ("  namespace: " + default_namespace + "%N")
			l_yaml.append ("type: Opaque%N")
			if not a_data.is_empty then
				l_yaml.append ("stringData:%N")
				from a_data.start until a_data.after loop
					l_yaml.append ("  " + a_data.key_for_iteration + ": %"" + a_data.item_for_iteration + "%"%N")
					a_data.forth
				end
			end
			documents.extend (l_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- Raw YAML

	add_raw (a_yaml: STRING)
			-- Add a pre-rendered document verbatim (no validation or conversion).
			-- Pass YAML text; JSON text is emitted as-is (use `add_json' to convert it).
		require
			not_empty: not a_yaml.is_empty
		do
			documents.extend (a_yaml)
		ensure
			added: document_count = old document_count + 1
		end

feature -- JSON resources

	is_json_object (a_json: STRING): BOOLEAN
			-- Is `a_json' well-formed JSON whose top-level value is an object?
		local
			l_parser: SIMPLE_JSON
		do
			if not a_json.is_empty then
				create l_parser
				if attached l_parser.parse (utf8_to_string_32 (a_json)) as l_value then
					Result := l_value.is_object
				end
			end
		end

	add_json (a_json: STRING)
			-- Add a resource given as a JSON object, converted to block-style YAML.
		require
			is_object: is_json_object (a_json)
		local
			l_parser: SIMPLE_JSON
			l_yaml: SIMPLE_YAML
			l_text: STRING_32
		do
			create l_parser
			create l_yaml.make
			if attached l_parser.parse (utf8_to_string_32 (a_json)) as l_value then
				l_text := l_yaml.to_yaml (to_yaml_value (l_value))
			else
				create l_text.make_empty
			end
			documents.extend ((create {UTF_CONVERTER}).string_32_to_utf_8_string_8 (l_text))
		ensure
			added: document_count = old document_count + 1
		end

feature -- Output

	to_yaml: STRING
			-- Generate combined YAML manifest.
		local
			l_first: BOOLEAN
			i: INTEGER
		do
			create Result.make (documents.count * 500)
			l_first := True
			from i := 1 until i > documents.count loop
				if not l_first then
					Result.append ("---%N")
				end
				Result.append (documents [i])
				l_first := False
				i := i + 1
			end
		ensure
			result_exists: Result /= Void
		end

	save_to_file (a_path: STRING): BOOLEAN
			-- Save manifest to file. Returns True on success.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: SIMPLE_FILE
		do
			create l_file.make (a_path)
			Result := l_file.set_content (to_yaml)
		end

feature -- Clearing

	clear
			-- Remove all documents.
		do
			documents.wipe_out
		ensure
			empty: is_empty
		end

feature {NONE} -- JSON conversion

	utf8_to_string_32 (a_text: STRING): STRING_32
			-- `a_text' (UTF-8 bytes) as Unicode.
		do
			Result := (create {UTF_CONVERTER}).utf_8_string_8_to_string_32 (a_text)
		end

	to_yaml_value (a_value: SIMPLE_JSON_VALUE): YAML_VALUE
			-- JSON tree `a_value' as a YAML tree (object key order preserved).
		local
			l_map: YAML_MAPPING
			l_seq: YAML_SEQUENCE
			l_object: SIMPLE_JSON_OBJECT
			l_array: SIMPLE_JSON_ARRAY
			l_keys: ARRAY [STRING_32]
			i: INTEGER
		do
			if a_value.is_object then
				create l_map.make
				l_object := a_value.as_object
				l_keys := l_object.keys
				from i := l_keys.lower until i > l_keys.upper loop
					if attached l_object.item (l_keys [i]) as l_child then
						l_map.put (to_yaml_value (l_child), l_keys [i])
					end
					i := i + 1
				end
				Result := l_map
			elseif a_value.is_array then
				create l_seq.make
				l_array := a_value.as_array
				from i := 1 until i > l_array.count loop
					l_seq.extend (to_yaml_value (l_array.item (i)))
					i := i + 1
				end
				Result := l_seq
			elseif a_value.is_string then
				create {YAML_STRING} Result.make (a_value.as_string_32)
			elseif a_value.is_boolean then
				create {YAML_BOOLEAN} Result.make (a_value.as_boolean)
			elseif a_value.is_integer then
				create {YAML_INTEGER} Result.make (a_value.as_integer)
			elseif a_value.is_number then
				create {YAML_FLOAT} Result.make (a_value.as_real)
			else
				create {YAML_NULL} Result.make
			end
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Implementation

	documents: ARRAYED_LIST [STRING]
			-- Collection of YAML documents.

invariant
	documents_not_void: documents /= Void
	namespace_not_void: default_namespace /= Void
	namespace_not_empty: not default_namespace.is_empty

end
