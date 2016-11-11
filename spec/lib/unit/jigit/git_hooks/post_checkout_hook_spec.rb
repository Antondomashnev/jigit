require "jigit/git/post_checkout_hook"

describe Jigit::PostCheckoutHook do
  it "has correct hook lines" do
    expected_lines = ["#!/usr/bin/env bash",
                      "checkoutType=$3",
                      "[[ $checkoutType == 1 ]] && checkoutType='branch' || checkoutType='file'",
                      "if [ $checkoutType == 'branch' ]; then",
                      "  newBranchName=`git symbolic-ref --short HEAD`",
                      "  oldBranchName=`git rev-parse --abbrev-ref @{-1}`",
                      "  if [ $newBranchName != $oldBranchName ]; then",
                      "    jigit issue start --name=$newBranchName",
                      "    jigit issue stop --name=$oldBranchName",
                      "  fi",
                      "fi"]
    expect(Jigit::PostCheckoutHook.hook_lines).to be == expected_lines
  end

  it "has correct name" do
    expect(Jigit::PostCheckoutHook.name).to be == "post-checkout"
  end
end
