#
# METADATA
# description: >-
#   To be able to reproduce and audit builds accurately it's important
#   to know exactly what happens during the build. To do this
#   Enterprise Contract requires that all tasks are defined in a set of
#   known and trusted task bundles. This package includes rules to
#   confirm that the tasks in a Pipeline definition are defined in task
#   bundles, and that the task bundles are from the list of known
#   and trusted bundles.
#
package policy.pipeline.task_bundle

import future.keywords.contains
import future.keywords.if
import future.keywords.in

import data.lib
import data.lib.bundles

# METADATA
# title: Task bundle was not used or is not defined
# description: >-
#   Check for the existence of a task bundle. This rule will
#   fail if the task is not called from a bundle.
# custom:
#   short_name: disallowed_task_reference
#   failure_msg: Pipeline task '%s' does not contain a bundle reference
#
deny contains result if {
	some task in bundles.disallowed_task_reference(input.spec.tasks)
	result := lib.result_helper(rego.metadata.chain(), [task.name])
}

# METADATA
# title: Task bundle reference is empty
# description: >-
#   Check that a valid task bundle reference is being used.
# custom:
#   short_name: empty_task_bundle_reference
#   failure_msg: Pipeline task '%s' uses an empty bundle image reference
#
deny contains result if {
	some task in bundles.empty_task_bundle_reference(input.spec.tasks)
	result := lib.result_helper(rego.metadata.chain(), [task.name])
}

# METADATA
# title: Unpinned task bundle reference
# description: >-
#   Check if the Tekton Bundle used for the Tasks in the Pipeline definition
#   is pinned to a digest.
# custom:
#   short_name: unpinned_task_bundle
#   failure_msg: Pipeline task '%s' uses an unpinned task bundle reference '%s'
#
warn contains result if {
	some task in bundles.unpinned_task_bundle(input.spec.tasks)
	result := lib.result_helper(rego.metadata.chain(), [task.name, bundles.bundle(task)])
}

# METADATA
# title: Task bundle is out of date
# description: >-
#   For each Task in the Pipeline definition, check if the Tekton Bundle used is
#   the most recent xref:acceptable_bundles.adoc#_task_bundles[acceptable bundle].
# custom:
#   short_name: out_of_date_task_bundle
#   failure_msg: Pipeline task '%s' uses an out of date task bundle '%s'
#
warn contains result if {
	some task in bundles.out_of_date_task_bundle(input.spec.tasks)
	result := lib.result_helper(rego.metadata.chain(), [task.name, bundles.bundle(task)])
}

# METADATA
# title: Task bundle is not acceptable
# description: >-
#   For each Task in the Pipeline definition, check if the Tekton Bundle used is an
#   xref:acceptable_bundles.adoc#_task_bundles[acceptable bundle] given the tracked
#   effective_on date.
# custom:
#   short_name: unacceptable_task_bundle
#   failure_msg: Pipeline task '%s' uses an unacceptable task bundle '%s'
#
deny contains result if {
	some task in bundles.unacceptable_task_bundle(input.spec.tasks)
	result := lib.result_helper(rego.metadata.chain(), [task.name, bundles.bundle(task)])
}

# METADATA
# title: Missing required data
# description: >-
#   Confirm the `task-bundles` rule data was provided, since it's
#   required by the policy rules in this package.
# custom:
#   short_name: missing_required_data
#   failure_msg: Missing required task-bundles data
deny contains result if {
	bundles.missing_task_bundles_data
	result := lib.result_helper(rego.metadata.chain(), [])
}
