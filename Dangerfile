# frozen_string_literal: true

github.dismiss_out_of_range_messages

# `files: []` forces rubocop to scan all files, not just the ones modified in the PR
rubocop.lint(files: [], force_exclusion: true, inline_comment: true, fail_on_inline_comment: true,
             include_cop_names: true)

manifest_pr_checker.check_gemfile_lock_updated

labels_checker.check(
  do_not_merge_labels: ['do not merge'],
  required_labels: [//], # At least one label, regardless of its name
  required_labels_error: 'You need to add at least one label to this PR'
)
