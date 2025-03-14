package lib.bundles_test

import future.keywords.in

import data.lib
import data.lib.bundles

# used as reference bundle data in tests
bundle_data := {"registry.img/acceptable": [{
	"digest": "sha256:digest",
	"tag": "",
	"effective_on": "2000-01-01T00:00:00Z",
}]}

# used as reference bundle data in tests
acceptable_bundle_ref := "registry.img/acceptable@sha256:digest"

test_disallowed_task_reference {
	tasks := [
		{"name": "my-task-1", "taskRef": {}},
		{"name": "my-task-2", "ref": {}},
	]

	expected := {task | some task in tasks}
	lib.assert_equal(bundles.disallowed_task_reference(tasks), expected)
}

test_empty_task_bundle_reference {
	tasks := [
		{"name": "my-task-1", "taskRef": {"bundle": ""}},
		{"name": "my-task-2", "ref": {"bundle": ""}},
	]

	expected := {task | some task in tasks}
	lib.assert_equal(bundles.empty_task_bundle_reference(tasks), expected)
}

test_unpinned_task_bundle {
	tasks := [
		{
			"name": "my-task-1",
			"taskRef": {"bundle": "reg.com/repo:903d49a833d22f359bce3d67b15b006e1197bae5"},
		},
		{
			"name": "my-task-2",
			"ref": {"bundle": "reg.com/repo:903d49a833d22f359bce3d67b15b006e1197bae5"},
		},
	]

	expected := {task | some task in tasks}
	lib.assert_equal(bundles.unpinned_task_bundle(tasks), expected)
}

# All good when the most recent bundle is used.
test_acceptable_bundle {
	tasks := [
		{"name": "my-task-1", "taskRef": {"bundle": "reg.com/repo@sha256:abc"}},
		{"name": "my-task-2", "ref": {"bundle": "reg.com/repo@sha256:abc"}},
	]

	lib.assert_empty(bundles.disallowed_task_reference(tasks)) with data["task-bundles"] as task_bundles
	lib.assert_empty(bundles.empty_task_bundle_reference(tasks)) with data["task-bundles"] as task_bundles
	lib.assert_empty(bundles.unpinned_task_bundle(tasks)) with data["task-bundles"] as task_bundles
	lib.assert_empty(bundles.out_of_date_task_bundle(tasks)) with data["task-bundles"] as task_bundles
	lib.assert_empty(bundles.unacceptable_task_bundle(tasks)) with data["task-bundles"] as task_bundles
}

test_out_of_date_task_bundle {
	tasks := [
		{"name": "my-task-1", "taskRef": {"bundle": "reg.com/repo@sha256:bcd"}},
		{"name": "my-task-2", "taskRef": {"bundle": "reg.com/repo@sha256:cde"}},
		{"name": "my-task-3", "ref": {"bundle": "reg.com/repo@sha256:bcd"}},
		{"name": "my-task-4", "ref": {"bundle": "reg.com/repo@sha256:cde"}},
	]

	expected := {task | some task in tasks}
	lib.assert_equal(bundles.out_of_date_task_bundle(tasks), expected) with data["task-bundles"] as task_bundles
}

test_unacceptable_task_bundles {
	tasks := [
		{"name": "my-task-1", "taskRef": {"bundle": "reg.com/repo@sha256:def"}},
		{"name": "my-task-2", "ref": {"bundle": "reg.com/repo@sha256:def"}},
	]

	expected := {task | some task in tasks}
	lib.assert_equal(bundles.unacceptable_task_bundle(tasks), expected) with data["task-bundles"] as task_bundles
}

test_is_equal {
	record := {"digest": "sha256:abc", "tag": "spam"}

	# Exact match
	lib.assert_equal(bundles.is_equal(record, {"digest": "sha256:abc", "tag": "spam"}), true)

	# Tag is ignored if digest matches
	lib.assert_equal(bundles.is_equal(record, {"digest": "sha256:abc", "tag": "not-spam"}), true)

	# Tag is not required
	lib.assert_equal(bundles.is_equal(record, {"digest": "sha256:abc", "tag": ""}), true)

	# When digest is missing on ref, compare tag
	lib.assert_equal(bundles.is_equal(record, {"digest": "", "tag": "spam"}), true)

	# If digest does not match, tag is still ignored
	lib.assert_equal(bundles.is_equal(record, {"digest": "sha256:bcd", "tag": "spam"}), false)

	# No match is honored when digest is missing
	lib.assert_equal(bundles.is_equal(record, {"digest": "", "tag": "not-spam"}), false)
}

task_bundles := {"reg.com/repo": [
	{
		"digest": "sha256:abc", # Allow
		"tag": "903d49a833d22f359bce3d67b15b006e1197bae5",
		"effective_on": "2262-04-11T00:00:00Z",
	},
	{
		"digest": "sha256:bcd", # Warn
		"tag": "b7d8f6ae908641f5f2309ee6a9d6b2b83a56e1af",
		"effective_on": "2262-03-11T00:00:00Z",
	},
	{
		"digest": "sha256:cde", # Warn
		"tag": "120dda49a6cc3b89516b491e19fe1f3a07f1427f",
		"effective_on": "2022-02-01T00:00:00Z",
	},
	{
		"digest": "sha256:def", # Warn
		"tag": "903d49a833d22f359bce3d67b15b006e1197bae5",
		"effective_on": "2021-01-01T00:00:00Z",
	},
]}

test_acceptable_bundle_is_acceptable {
	bundles.is_acceptable(acceptable_bundle_ref) with data["task-bundles"] as bundle_data
}

test_unacceptable_bundle_is_unacceptable {
	not bundles.is_acceptable("registry.img/unacceptable@sha256:digest") with data["task-bundles"] as bundle_data
}

test_missing_required_data {
	lib.assert_equal(bundles.missing_task_bundles_data, false) with data["task-bundles"] as task_bundles
	lib.assert_equal(bundles.missing_task_bundles_data, true) with data["task-bundles"] as []
}
