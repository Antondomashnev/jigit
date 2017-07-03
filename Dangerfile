# We all want to know that =)
simplecov.report 'coverage/coverage.json'

has_app_changes = !git.modified_files.grep(/lib/).empty?
has_test_changes = !git.modified_files.grep(/spec/).empty?

github.review.start

if has_app_changes && !has_test_changes
  github.review.warn("Tests were not updated")
end

# People are curious about what you've done
if github.pr_title.length < 5
  github.review.fail "Please provide a meaningful Pull Request title"
end

if github.pr_body.length < 5
  github.review.fail "Please provide a summary in the Pull Request description"
end

github.review.submit

# Changelog is important
declared_trivial = (github.pr_title + github.pr_body).include?("#trivial") || !has_app_changes
changelog.check unless declared_trivial
