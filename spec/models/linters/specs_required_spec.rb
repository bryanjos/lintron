require 'rails_helper'

describe Linters::SpecsRequired do
  let(:pr_missing_rb_spec) do
    PRMissingRBSpec.new
  end

  let(:pr_missing_es_spec) do
    PRMissingESSpec.new
  end

  let(:pr_with_all_specs) do
    PRWithAllSpecs.new
  end

  it 'catches missing specs for rb files' do
    linter = Linters::SpecsRequired.new
    violations = linter.run(pr_missing_rb_spec)
    expect(violations.length).to eq 1
    expect(violations.first.message).to include 'post_spec'
  end

  it 'catches missing specs for es6 files' do
    linter = Linters::SpecsRequired.new
    violations = linter.run(pr_missing_es_spec)
    expect(violations.length).to eq 1
    expect(violations.first.message).to include 'post_spec'
  end

  it 'ignores PRs with all the correct specs' do
    linter = Linters::SpecsRequired.new
    violations = linter.run(pr_with_all_specs)
    expect(violations.length).to eq 0
  end
end
