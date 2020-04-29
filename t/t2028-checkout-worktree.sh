#!/bin/sh

test_description='checkout --worktree'

. ./test-lib.sh

test_expect_success setup '
	echo first >file1 &&
	echo file2 >file2 &&
	git add file1 file2 &&
	git commit -m first &&

	echo second >file1 &&
	git commit -am second &&
	git tag tip
'

test_expect_success 'checkout --worktree on a commit' '
	test_when_finished "git reset --hard tip" &&
	git diff HEAD HEAD~ >expect &&
	git checkout --worktree HEAD~ file1 &&
	git diff >actual &&
	test_cmp expect actual &&
	git diff --cached --exit-code &&
	test_cmp_rev HEAD tip
'

test_expect_success 'checkout --worktree with no commit' '
	test_when_finished "git reset --hard tip" &&
	echo worktree >file1 &&
	git checkout --worktree file1 &&
	git diff --exit-code &&
	test_cmp_rev HEAD tip
'

test_expect_success 'checkout --worktree without pathspec fails' '
	test_must_fail git checkout --worktree
'

test_expect_success 'checkout --no-worktree fails' '
	test_must_fail git checkout --no-worktree
'

test_expect_success PERL 'git checkout -p --worktree' '
	test_when_finished "git reset --hard tip" &&
	echo changed >file2 &&
	git diff -R --src-prefix=b/ --dst-prefix=a/ >expect &&
	git commit -am file12 &&
	test_write_lines n y | git checkout --worktree -p HEAD~2 &&
	git diff >actual &&
	test_cmp expect actual &&
	git diff --cached --exit-code
'

test_done
