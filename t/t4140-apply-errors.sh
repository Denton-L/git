#!/bin/sh

test_description='bad patches report errors appropriately'

. ./test-lib.sh

test_expect_success setup '
	test_write_lines a b c>file &&
	git add file &&
	test_commit commit
'

test_patch () {
	name="$1" &&
	error="${2:-"$name"}" &&
	cat >patch &&
	test_expect_success "$name" "
		test_must_fail git apply --check patch 2>err &&
		test_i18ngrep \"$error\" err
	"
}

test_patch 'negative hunk offset before' 'negative hunk offset' <<-\EOF
diff --git a/file b/file
index de98044..d68dd40 100644
--- a/file
+++ b/file
@@ -1,-3 +1,4 @@
 a
 b
 c
+d
EOF

test_patch 'negative hunk offset after' 'negative hunk offset' <<-\EOF
diff --git a/file b/file
index de98044..d68dd40 100644
--- a/file
+++ b/file
@@ -1,3 +1,-4 @@
 a
 b
 c
+d
EOF

test_patch 'invalid first-character' <<-\EOF
diff --git a/file b/file
index de98044..d68dd40 100644
--- a/file
+++ b/file
@@ -1,3 +1,4 @@
 a
 b
 c
*d
EOF

test_patch 'was expecting line with \\\\ to be \"\\\\ No newline at end of file\"' <<-\EOF
diff --git a/file b/file
index de98044..1c943a9 100644
--- a/file
+++ b/file
@@ -1,3 +1,3 @@
 a
 b
-c
\
+c
EOF

test_patch 'header mismatch in before' 'mismatch between hunk header and actual number of lines' <<-\EOF
diff --git a/file b/file
index de98044..d68dd40 100644
--- a/file
+++ b/file
@@ -1,2 +1,4 @@
 a
 b
 c
+d
EOF

test_patch 'header mismatch in after' 'mismatch between hunk header and actual number of lines' <<-\EOF
diff --git a/file b/file
index de98044..d68dd40 100644
--- a/file
+++ b/file
@@ -1,3 +1,5 @@
 a
 b
 c
+d
EOF

test_patch 'no lines added or removed' <<-\EOF
diff --git a/file b/file
index de98044..d68dd40 100644
--- a/file
+++ b/file
@@ -1,3 +1,3 @@
 a
 b
 c
EOF

test_patch 'new file depends on old contents' <<-\EOF
diff --git a/newfile b/newfile
new file mode 100644
index 0000000..de98044
--- /dev/null
+++ b/newfile
@@ -1,3 +1,2 @@
-a
 b
 c
EOF

test_patch 'deleted file still has contents' <<-\EOF
diff --git a/file b/file
deleted file mode 100644
index de98044..0000000
--- a/file
+++ /dev/null
@@ -1,3 +1,4 @@
 a
 b
 c
+d
EOF

test_done
