require "test_helper"

class RoadmapControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    RoadmapParser.any_instance.stubs(:parse).returns([
      { title: "Short term", description: "Stabilize and polish the core", items: [ { title: "Reliability, performance, and technical debt", status: "In progress", description: nil } ] },
      { title: "Medium term", description: "Expand personal-finance capability", items: [ { title: "First-class AI", status: "Exploring", description: nil } ] },
      { title: "Long term", description: "Open the platform carefully", items: [ { title: "Business finance support", status: "Exploring", description: nil } ] }
    ])
  end

  test "roadmap page renders curated phases from markdown" do
    get roadmap_url

    assert_response :success
    assert_select "title", text: "Roadmap - Sure"
    assert_select "h1", text: "The Roadmap"
    assert_select "details", count: 3
    assert_select "details:not([open])", count: 3
    assert_select "summary", text: /Stabilize and polish the core/
    assert_select "h2", text: "Reliability, performance, and technical debt"
  end

  test "caches parsed roadmap phases between requests" do
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    parser = mock
    RoadmapParser.expects(:new).once.returns(parser)
    parser.expects(:parse).once.returns([])

    get roadmap_url
    get roadmap_url

    assert_response :success
  ensure
    Rails.cache = original_cache
  end

  test "roadmap page renders an empty state without phases or items" do
    RoadmapParser.any_instance.stubs(:parse).returns([])

    get roadmap_url

    assert_response :success
    assert_select "details", count: 0
    assert_select "p", text: "The roadmap is temporarily unavailable. Please check back soon."
  end
end
