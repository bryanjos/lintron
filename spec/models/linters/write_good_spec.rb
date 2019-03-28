require 'rails_helper'

describe Linters::WriteGood do
  it 'can lint markdown without error' do
    source = <<-MARKDOWN
    ## Setting Up Webhooks

    Lintron uses webhooks to know when a PR has been created or updated. You'll need to set up the webhook on each repo you want Lintron to monitor.

    Log into your Lintron instance with your GitHub credentials. You will be taken to a page (`/hooks`) where you can attach Lintron's required hooks to a repo.

    Alternatively, you can set up the webhooks manually:
    MARKDOWN

    file = StubFile.new(
      path: 'test.md',
      blob: source,
    )

    lints = Linters::WriteGood.new.run(file)

    expect(lints).to_not be_empty
  end

  it 'can lint txt without error' do
    source = <<-TEXT
    ## Setting Up Webhooks

    Lintron uses webhooks to know when a PR has been created or updated. You'll need to set up the webhook on each repo you want Lintron to monitor.

    Log into your Lintron instance with your GitHub credentials. You will be taken to a page (`/hooks`) where you can attach Lintron's required hooks to a repo.

    Alternatively, you can set up the webhooks manually:
    TEXT

    file = StubFile.new(
      path: 'test.txt',
      blob: source,
    )

    lints = Linters::WriteGood.new.run(file)

    expect(lints).to_not be_empty
  end
end
