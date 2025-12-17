note
	description: "Kubernetes API error representation"
	author: "Larry Rix"

class
	K8S_ERROR

create
	make,
	make_from_status

feature {NONE} -- Initialization

	make (a_message: STRING)
			-- Create error with message.
		require
			message_not_empty: not a_message.is_empty
		do
			message := a_message
			http_status := 0
		ensure
			message_set: message.same_string (a_message)
		end

	make_from_status (a_status: INTEGER; a_body: STRING)
			-- Create from HTTP status and response body.
		require
			body_not_void: a_body /= Void
		do
			http_status := a_status
			if a_status = 401 then
				message := "Unauthorized"
			elseif a_status = 403 then
				message := "Forbidden"
			elseif a_status = 404 then
				message := "Not Found"
			elseif a_status = 409 then
				message := "Conflict"
			elseif a_status >= 500 then
				message := "Server Error"
			else
				message := "HTTP " + a_status.out
			end
			raw_response := a_body
		ensure
			status_set: http_status = a_status
		end

feature -- Access

	message: STRING
			-- Error message.
		attribute
			create Result.make_empty
		end

	http_status: INTEGER
			-- HTTP status code (0 if not HTTP error).

	raw_response: detachable STRING
			-- Raw response body if available.

feature -- Query

	is_unauthorized: BOOLEAN
			-- Is this an authentication error?
		do
			Result := http_status = 401
		end

	is_forbidden: BOOLEAN
			-- Is this an authorization error?
		do
			Result := http_status = 403
		end

	is_not_found: BOOLEAN
			-- Was resource not found?
		do
			Result := http_status = 404
		end

	is_server_error: BOOLEAN
			-- Is this a server-side error?
		do
			Result := http_status >= 500
		end

feature -- Output

	to_string: STRING
			-- Human readable error.
		do
			if http_status > 0 then
				Result := "HTTP " + http_status.out + ": " + message
			else
				Result := message
			end
		ensure
			result_not_void: Result /= Void
		end

invariant
	message_not_void: message /= Void

end
