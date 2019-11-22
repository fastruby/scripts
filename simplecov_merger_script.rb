class SimpleCovMerger
  def self.report_coverage(base_dir:, ci_project_path:, project_path:)
    new(base_dir: base_dir, ci_project_path: ci_project_path, project_path: project_path).merge_results
  end

  attr_reader :base_dir, :ci_project_path, :project_path

  def initialize(base_dir:, ci_project_path:, project_path:)
    @base_dir = base_dir
    @ci_project_path = ci_project_path
    @project_path = project_path
  end

  def merge_results
    require "simplecov"
    require "json"

    results = resultsets.map do |file|
      hash_result = JSON.parse(clean(File.read(file)))
      SimpleCov::Result.from_hash(hash_result)
    end

    result = SimpleCov::ResultMerger.merge_results(*results)

    SimpleCov::ResultMerger.store_result(result)
  end

  private

  def resultsets
    Dir["#{base_dir}/.resultset-*.json"]
  end

  def clean(results)
    results.gsub(ci_project_path, project_path)
  end
end


# Usage:

# base_dir         - This is the directory where you stored all your `.resultset.json` from your different containers/machines from your CI service
# ci\_project\_path  - The path where your project is stored in your CI service
# project_path     - The path of the project you are generating a coverage report

# SimpleCovMerger.report_coverage(base_dir: "./resultsets", ci_project_path: "/home/ubuntu/the_project/", project_path: "/Users/bronzdoc/projects/fastruby/the_project/")

