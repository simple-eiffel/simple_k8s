note
	description: "Kubernetes authentication handler"
	author: "Larry Rix"

class
	K8S_AUTH

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize authentication handler.
		do
			create cached_token.make_empty
		end

feature -- Operations

	configure_http (a_http: SIMPLE_HTTP; a_config: K8S_CONFIG)
			-- Configure HTTP client with authentication from config.
		require
			http_not_void: a_http /= Void
			config_not_void: a_config /= Void
		do
			-- Set JSON content types
			a_http.set_accept_json
			a_http.set_content_type_json

			-- Configure authentication based on config
			if attached a_config.bearer_token as l_token and then not l_token.is_empty then
				a_http.set_bearer_token (l_token)
			elseif attached cached_token and then not cached_token.is_empty then
				a_http.set_bearer_token (cached_token)
			end
		end

	set_token (a_token: STRING)
			-- Set bearer token for authentication.
		require
			token_not_empty: not a_token.is_empty
		do
			cached_token := a_token
		ensure
			token_set: cached_token.same_string (a_token)
		end

	clear_token
			-- Clear cached token.
		do
			create cached_token.make_empty
		ensure
			token_cleared: cached_token.is_empty
		end

feature -- Query

	has_token: BOOLEAN
			-- Is a token available?
		do
			Result := not cached_token.is_empty
		end

feature {NONE} -- Implementation

	cached_token: STRING
			-- Cached bearer token.

invariant
	cached_token_not_void: cached_token /= Void

end
