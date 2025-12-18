note
	description: "HTTP client wrapper for Kubernetes API calls"
	author: "Larry Rix"

class
	K8S_HTTP

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize HTTP client.
		do
			create http.make
		end

feature -- Access

	http: SIMPLE_HTTP
			-- Underlying HTTP client.

feature -- HTTP Operations

	http_get (a_url: STRING): SIMPLE_HTTP_RESPONSE
			-- Perform GET request.
		require
			url_not_empty: not a_url.is_empty
		do
			Result := http.get (a_url)
		end

	http_post (a_url, a_body: STRING): SIMPLE_HTTP_RESPONSE
			-- Perform POST request with JSON body.
		require
			url_not_empty: not a_url.is_empty
		do
			http.set_content_type_json
			Result := http.post (a_url, a_body)
		end

	http_delete (a_url: STRING): SIMPLE_HTTP_RESPONSE
			-- Perform DELETE request.
		require
			url_not_empty: not a_url.is_empty
		do
			Result := http.delete (a_url)
		end

	http_patch (a_url, a_body: STRING): SIMPLE_HTTP_RESPONSE
			-- Perform PATCH request with strategic merge patch content type.
		require
			url_not_empty: not a_url.is_empty
		do
			http.add_header ("Content-Type", "application/strategic-merge-patch+json")
			Result := http.patch (a_url, a_body)
		end

feature -- Utility

	current_datetime: DATE_TIME
			-- Current date/time for timestamps.
		do
			create Result.make_now
		end

feature -- Header Configuration

	set_bearer_token (a_token: STRING)
			-- Set Authorization header with bearer token.
		require
			token_not_empty: not a_token.is_empty
		do
			http.set_bearer_token (a_token)
		end

	set_header (a_name, a_value: STRING)
			-- Set custom header.
		require
			name_not_empty: not a_name.is_empty
		do
			http.add_header (a_name, a_value)
		end

end
