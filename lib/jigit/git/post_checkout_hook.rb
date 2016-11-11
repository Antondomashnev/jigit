require "jigit/git/git_hook"

module Jigit
  class PostCheckoutHook < GitHook
    def self.hook_lines
      ["#!/usr/bin/env bash",
       "checkoutType=$3",
       "[[ $checkoutType == 1 ]] && checkoutType='branch' || checkoutType='file'",
       "if [ $checkoutType == 'branch' ]; then",
       "  newBranchName=`git symbolic-ref --short HEAD`",
       "  oldBranchName=`git rev-parse --abbrev-ref @{-1}`",
       "  if [ $newBranchName != $oldBranchName ]; then",
       "    jigit issue start_issue --name=$newBranchName",
       "    jigit issue stop_issue --name=$oldBranchName",
       "  fi",
       "fi"]
    end

    def self.name
      "post-checkout"
    end
  end
end
