import Gravatar
import TestHelpers
import Testing
import UIKit

struct TestImageCacheTests {
    private let readyKey = "ReadyKey"
    private let inProgressKey = "InProgressKey"

    @Test("Ready with Image")
    func readyEntryWithImage() async throws {
        let cache = TestImageCache()
        let testImage = ImageHelper.testImage

        // There should be no access to cache entries yet
        #expect(cache.setImageCallsCount == 0)
        #expect(cache.getImageCallsCount == 0)
        #expect(cache.setTaskCallsCount == 0)

        // Set an entry
        cache.setEntry(.ready(testImage), for: readyKey)

        // Fetch the entry
        switch try #require(cache.getEntry(with: readyKey)) {
        case .ready(let image):
            #expect(testImage == image)
            #expect(cache.setImageCallsCount == 1)
            #expect(cache.getImageCallsCount == 1)
            #expect(cache.setTaskCallsCount == 0)
        default:
            #expect(Bool(false))
        }
    }

    @Test("In Progress with Task")
    func inProgressEntryWithTask() async throws {
        let cache = TestImageCache()
        let task = Task<UIImage, Error> {
            ImageHelper.testImage
        }

        // There should be no access to cache entries yet
        #expect(cache.setImageCallsCount == 0)
        #expect(cache.getImageCallsCount == 0)
        #expect(cache.setTaskCallsCount == 0)

        // Set an entry
        cache.setEntry(.inProgress(task), for: inProgressKey)

        // Fetch the entry
        switch try #require(cache.getEntry(with: inProgressKey)) {
        case .inProgress(let fetchedTask):
            #expect(task == fetchedTask)
            let fetchedImage = try #require(await fetchedTask.value)
            #expect(ImageHelper.testImage.pngData() == fetchedImage.pngData())
            #expect(cache.getImageCallsCount == 1)
            #expect(cache.setImageCallsCount == 0)
            #expect(cache.setTaskCallsCount == 1)
        default:
            #expect(Bool(false))
        }
    }

    @Test("Set entry to nil")
    func setEntryToNil() async throws {
        let cache = TestImageCache()
        let task = Task<UIImage, Error> {
            ImageHelper.testImage
        }

        // There should be no access to cache entries yet
        #expect(cache.setImageCallsCount == 0)
        #expect(cache.getImageCallsCount == 0)
        #expect(cache.setTaskCallsCount == 0)
        #expect(cache.setToNilCount == 0)

        // Set entries
        cache.setEntry(.ready(ImageHelper.testImage), for: readyKey)
        cache.setEntry(.inProgress(task), for: inProgressKey)

        // Check that entries were set
        #expect(try cache.getEntry(with: readyKey) != nil)
        #expect(try cache.getEntry(with: inProgressKey) != nil)

        // Set one entry to nil
        cache.setEntry(nil, for: readyKey)

        // Check that only one entry was set to nil
        #expect(try cache.getEntry(with: readyKey) == nil)
        #expect(try cache.getEntry(with: inProgressKey) != nil)

        // Count the number of each type of cache access
        #expect(cache.setImageCallsCount == 1)
        #expect(cache.getImageCallsCount == 4)
        #expect(cache.setTaskCallsCount == 1)
        #expect(cache.setToNilCount == 1)
    }

    @Test("Cache Clears")
    func cacheClears() async throws {
        let cache = TestImageCache()
        let testImage = ImageHelper.testImage
        let task = Task<UIImage, Error> {
            ImageHelper.testImage
        }

        // There should be no access to cache entries yet
        #expect(cache.setImageCallsCount == 0)
        #expect(cache.getImageCallsCount == 0)
        #expect(cache.setTaskCallsCount == 0)
        #expect(cache.setToNilCount == 0)
        #expect(cache.clearCallsCount == 0)

        // Set entries
        cache.setEntry(.ready(testImage), for: readyKey)
        cache.setEntry(.inProgress(task), for: inProgressKey)

        // Check that entries were set
        #expect(try cache.getEntry(with: readyKey) != nil)
        #expect(try cache.getEntry(with: inProgressKey) != nil)

        // Count the number of each type of cache access
        #expect(cache.getImageCallsCount == 2)
        #expect(cache.setTaskCallsCount == 1)
        #expect(cache.setTaskCallsCount == 1)
        #expect(cache.setToNilCount == 0)
        #expect(cache.clearCallsCount == 0)

        // Clear cache
        cache.clear()

        // Check that entries were removed
        #expect(try cache.getEntry(with: readyKey) == nil)
        #expect(try cache.getEntry(with: inProgressKey) == nil)

        // Count the number of each type of cache access
        #expect(cache.getImageCallsCount == 4)
        #expect(cache.setTaskCallsCount == 1)
        #expect(cache.setTaskCallsCount == 1)
        #expect(cache.setToNilCount == 0)
        #expect(cache.clearCallsCount == 1)
    }

    @Test("Concurrent Set, Get, Clear")
    func concurrentSetGetClear() async throws {
        let cache = TestImageCache()
        let testKey = "imageKey"
        let testImage = ImageHelper.testImage

        // Start concurrent `set`, `get`, and `clear` tasks against the cache
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 1000 {
                group.addTask {
                    cache.setEntry(.ready(testImage), for: testKey)
                }

                group.addTask {
                    _ = cache.getEntry(with: testKey)
                }

                group.addTask {
                    cache.clear()
                }
            }
        }

        #expect(cache.getImageCallsCount == 1000)
        #expect(cache.setImageCallsCount == 1000)
        #expect(cache.clearCallsCount == 1000)
    }

    @Test("Multiple Threads Modifying Cache")
    func multipleThreadsModifyingCache() async throws {
        let cache = TestImageCache()
        let testImage = ImageHelper.testImage
        let testImageTask = Task<UIImage, Error> { testImage }

        // Start concurrent `inProgress`, `ready`, and `get` tasks against the cache
        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< 1000 {
                let key = "key\(i)"

                group.addTask {
                    cache.setEntry(.inProgress(testImageTask), for: key)
                }

                group.addTask {
                    cache.setEntry(.ready(testImage), for: key)
                }

                group.addTask {
                    let imageEntry = cache.getEntry(with: key)
                    switch imageEntry {
                    case .ready(let image):
                        #expect(image === testImage)
                    case .inProgress(let task):
                        do {
                            let image = try #require(await task.value)
                            #expect(image == testImage)
                        } catch {
                            Issue.record("An image should have been found in the cache")
                        }
                    default:
                        Issue.record("An image should have been found in the cache")
                    }
                }
            }
        }

        // Expect each key to have one entry of each type
        for i in 0 ..< 1000 {
            #expect(cache.messageCount(type: .inProgress, forKey: "key\(i)") == 1)
            #expect(cache.messageCount(type: .ready, forKey: "key\(i)") == 1)
            #expect(cache.messageCount(type: .get, forKey: "key\(i)") == 1)
        }
    }
}
