note
	description: "Summary description for {TEST_APP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize Current
		do

		end

feature {NONE} -- Implementation

	lib_tests: detachable LIB_TESTS

end
