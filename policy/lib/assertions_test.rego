package lib_test

import data.lib

test_assert_equal {
	lib.assert_equal("a", "a")
	lib.assert_equal({"a": 10}, {"a": 10})
	lib.assert_equal(["a"], ["a"])
	lib.assert_equal({"a"}, {"a"})
	not lib.assert_equal("a", "b")
	not lib.assert_equal({"a": 10}, {"a", 11})
	not lib.assert_equal(["a"], ["b"])
	not lib.assert_equal({"a"}, {"b"})
}

test_assert_not_equal {
	lib.assert_not_equal("a", "b")
	lib.assert_not_equal({"a": 10}, {"a", 11})
	lib.assert_not_equal(["a"], ["b"])
	lib.assert_not_equal({"a"}, {"b"})
	not lib.assert_not_equal("a", "a")
	not lib.assert_not_equal({"a": 10}, {"a": 10})
	not lib.assert_not_equal(["a"], ["a"])
	not lib.assert_not_equal({"a"}, {"a"})
}

test_assert_empty {
	lib.assert_empty([])
	lib.assert_empty({})
	lib.assert_empty(set())
	not lib.assert_empty(["a"])
	not lib.assert_empty({"a"})
	not lib.assert_empty({"a": "b"})
}

test_assert_not_empty {
	lib.assert_not_empty(["a"])
	lib.assert_not_empty({"a"})
	lib.assert_not_empty({"a": "b"})
	not lib.assert_not_empty([])
	not lib.assert_not_empty({})
	not lib.assert_not_empty(set())
}

# regal ignore:rule-length
test_assert_equal_results {
	# Empty results
	lib.assert_equal_results(set(), set())
	lib.assert_equal_results({{}}, {{}})

	# collections attribute is ignored
	lib.assert_equal_results({{"collections": ["a", "b"]}}, {{}})
	lib.assert_equal_results({{}}, {{"collections": ["a", "b"]}})
	lib.assert_equal_results({{"collections": ["a", "b"]}}, {{"collections": ["c", "d"]}})
	lib.assert_equal_results(
		{{"spam": "maps", "collections": ["a", "b"]}},
		{{"spam": "maps", "collections": ["c", "d"]}},
	)

	# effective_on attribute is ignored
	lib.assert_equal_results({{"effective_on": "2022-01-01T00:00:00Z"}}, {{}})
	lib.assert_equal_results({{}}, {{"effective_on": "2022-01-01T00:00:00Z"}})
	lib.assert_equal_results(
		{{"effective_on": "2022-01-01T00:00:00Z"}},
		{{"effective_on": "1970-01-01T00:00:00Z"}},
	)
	lib.assert_equal_results(
		{{"spam": "maps", "effective_on": "2022-01-01T00:00:00Z"}},
		{{"spam": "maps", "effective_on": "1970-01-01T00:00:00Z"}},
	)

	# both collections and effective_on attributes are ignored
	lib.assert_equal_results(
		{{"spam": "maps", "collections": ["a", "b"], "effective_on": "2022-01-01T00:00:00Z"}},
		{{"spam": "maps", "collections": ["c", "d"], "effective_on": "1970-01-01T00:00:00Z"}},
	)

	# any other attribute is not ignored
	not lib.assert_equal_results(
		{{"spam": "maps", "collections": ["a", "b"], "effective_on": "2022-01-01T00:00:00Z"}},
		{{"collections": ["c", "d"], "effective_on": "1970-01-01T00:00:00Z"}},
	)

	# missing attributes in one result is not ignored
	not lib.assert_equal_results(
		{{"spam": "SPAM", "collections": ["a", "b"], "effective_on": "2022-01-01T00:00:00Z"}},
		{{"collections": ["c", "d"], "effective_on": "1970-01-01T00:00:00Z"}},
	)
	not lib.assert_equal_results(
		{{"collections": ["c", "d"], "effective_on": "1970-01-01T00:00:00Z"}},
		{{"spam": "SPAM", "collections": ["a", "b"], "effective_on": "2022-01-01T00:00:00Z"}},
	)

	# fallback for unexpected types
	lib.assert_equal_results({"spam", "maps"}, {"spam", "maps"})
	not lib.assert_equal_results({"spam", "maps"}, "spam")
	not lib.assert_equal_results(
		# These are "objects" instead of the expected "set of objects"
		{"spam": "maps", "collections": ["a", "b"], "effective_on": "2022-01-01T00:00:00Z"},
		{"spam": "maps", "collections": ["c", "d"], "effective_on": "1970-01-01T00:00:00Z"},
	)
}
